package io.flutter.plugins.googlesignin;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.FlutterMethodChannel;
import io.flutter.plugin.common.FlutterMethodChannel.MethodCallHandler;
import io.flutter.plugin.common.FlutterMethodChannel.Response;
import io.flutter.plugin.common.MethodCall;

import java.util.HashMap;
import java.util.Map;

/**
 * GoogleSignIn
 */
public class GoogleSignInPlugin implements MethodCallHandler {
  private FlutterActivity activity;
  private final String CHANNEL = "plugins.flutter.io/google_sign_in";

  public static void register(FlutterActivity activity) {
    new GoogleSignInPlugin(activity);
  }

  private GoogleSignInPlugin(FlutterActivity activity) {
    this.activity = activity;
    new FlutterMethodChannel(activity.getFlutterView(), CHANNEL)
      .setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(MethodCall call, Response response) {
    final JSONObject arguments = (JSONObject) call.arguments;
    switch (call.method) {
      case METHOD_INIT:
        init(response, getScopesArgument(arguments), getStringArgument(arguments, "hostedDomain"));
        break;

      case METHOD_SIGN_IN_SILENTLY:
        signInSilently(response);
        break;

      case METHOD_SIGN_IN:
        signIn(response);
        break;

      case METHOD_GET_TOKEN:
        getToken(response, getStringArgument(arguments, "email"));
        break;

      case METHOD_SIGN_OUT:
        signOut(response);
        break;

      case METHOD_DISCONNECT:
        disconnect(response);
        break;

      default:
        throw new IllegalArgumentException("Unknown method " + call.method);
    }
  }

  /**
    * Extracts the argument with the specified ket from the specified arguments object, expecting it
    * to be a String.
    */
   private static String getStringArgument(JSONObject arguments, String key) {
     try {
       if (!arguments.isNull(key)) {
         return arguments.getString(key);
       }
     } catch (JSONException e) {
       Log.e(TAG, "JSON exception", e);
     }
     return null;
   }

   /**
    * Initializes this listener so that it is ready to perform other operations. The Dart code
    * guarantees that this will be called and completed before any other methods are invoked.
    */
   private void init(MessageResponse response, List<String> requestedScopes, String hostedDomain) {
     try {
       if (googleApiClient != null) {
         // This can happen if the scopes change, or a full restart hot reload
         googleApiClient.stopAutoManage(activity);
         googleApiClient = null;
       }
       GoogleSignInOptions.Builder optionsBuilder =
           new GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN);
       optionsBuilder.requestEmail();
       for (String scope : requestedScopes) {
         optionsBuilder.requestScopes(new Scope(scope));
       }
       if (!Strings.isNullOrEmpty(hostedDomain)) {
         optionsBuilder.setHostedDomain(hostedDomain);
       }

       this.requestedScopes = requestedScopes;
       this.googleApiClient =
           new GoogleApiClient.Builder(activity)
               .enableAutoManage(activity, this)
               .addApi(Auth.GOOGLE_SIGN_IN_API, optionsBuilder.build())
               .addConnectionCallbacks(this)
               .build();
     } catch (Exception e) {
       Log.e(TAG, "Initialization error", e);
       response.send(getFailureResponse(ERROR_REASON_EXCEPTION, e.getMessage()));
     }

     // We're not initialized until we receive `onConnected`.
     // If initialization fails, we'll receive `onConnectionFailed`
     pendingOperation = new PendingOperation(METHOD_INIT, response);
   }

   /**
    * Handles the case of a concurrent operation already in progress.
    *
    * <p>Only one type of operation is allowed to be executed at a time, so if there's a pending
    * operation for a method type other than the current invocation, this will respond failure on the
    * specified response channel. Alternatively, if there's a pending operation for the same method
    * type, this will signal that the method is already being handled and add the specified response
    * to the pending operation's response queue.
    *
    * <p>If there's no pending operation, this method will set the pending operation to the current
    * invocation.
    *
    * @param currentMethod The current invocation.
    * @param response The response channel for the current invocation.
    * @return true iff an operation is already in progress (and thus the response is already being
    *     handled).
    */
   private boolean checkAndSetPendingOperation(String currentMethod, MessageResponse response) {
     if (pendingOperation == null) {
       pendingOperation = new PendingOperation(currentMethod, response);
       return false;
     }

     if (pendingOperation.method.equals(currentMethod)) {
       // This method is already being handled
       pendingOperation.responseQueue.add(response);
     } else {
       // Only one type of operation can be in progress at a time
       response.send(
           getFailureResponse(ERROR_REASON_OPERATION_IN_PROGRESS, pendingOperation.method));
     }

     return true;
   }

   /**
    * Returns the account information for the user who is signed in to this app. If no user is signed
    * in, tries to sign the user in without displaying any user interface.
    */
   private void signInSilently(MessageResponse response) {
     if (checkAndSetPendingOperation(METHOD_SIGN_IN, response)) {
       return;
     }

     OptionalPendingResult<GoogleSignInResult> pendingResult =
         Auth.GoogleSignInApi.silentSignIn(googleApiClient);
     if (pendingResult.isDone()) {
       onSignInResult(pendingResult.get());
     } else {
       pendingResult.setResultCallback(
           new ResultCallback<GoogleSignInResult>() {
             @Override
             public void onResult(GoogleSignInResult result) {
               onSignInResult(result);
             }
           });
     }
   }

   /**
    * Signs the user in via the sign-in user interface, including the OAuth consent flow if scopes
    * were requested.
    */
   private void signIn(MessageResponse response) {
     if (checkAndSetPendingOperation(METHOD_SIGN_IN, response)) {
       return;
     }

     Intent signInIntent = Auth.GoogleSignInApi.getSignInIntent(googleApiClient);
     activity.startActivityForResult(signInIntent, requestCode);
   }

   /**
    * Gets an OAuth access token with the scopes that were specified during {@link
    * #init(MessageResponse,List<String>) initialization} for the user with the specified email
    * address.
    */
   private void getToken(MessageResponse response, final String email) {
     if (email == null) {
       response.send(getFailureResponse(ERROR_REASON_EXCEPTION, "Email is null"));
       return;
     }

     if (checkAndSetPendingOperation(METHOD_GET_TOKEN, response)) {
       return;
     }

     Callable<String> getTokenTask =
         new Callable<String>() {
           @Override
           public String call() throws Exception {
             Account account = new Account(email, "com.google");
             String scopesStr = "oauth2:" + Joiner.on(' ').join(requestedScopes);
             return GoogleAuthUtil.getToken(activity.getApplication(), account, scopesStr);
           }
         };

     backgroundTaskRunner.runInBackground(
         getTokenTask,
         new Callback<String>() {
           @Override
           public void run(Future<String> tokenFuture) {
             try {
               finishOperation(getTokenResponse(tokenFuture.get()));
             } catch (ExecutionException e) {
               Log.e(TAG, "Exception getting access token", e);
               finishOperation(
                   getFailureResponse(ERROR_REASON_EXCEPTION, e.getCause().getMessage()));
             } catch (InterruptedException e) {
               finishOperation(getFailureResponse(ERROR_REASON_EXCEPTION, e.getMessage()));
             }
           }
         });
   }

   /**
    * Signs the user out. Their credentials may remain valid, meaning they'll be able to silently
    * sign back in.
    */
   private void signOut(MessageResponse response) {
     if (checkAndSetPendingOperation(METHOD_SIGN_OUT, response)) {
       return;
     }

     Auth.GoogleSignInApi.signOut(googleApiClient)
         .setResultCallback(
             new ResultCallback<Status>() {
               @Override
               public void onResult(Status status) {
                 // TODO(tvolkert): communicate status back to user
                 finishOperation(EMPTY_SUCCESS_JSON);
               }
             });
   }

   /** Signs the user out, and revokes their credentials. */
   private void disconnect(MessageResponse response) {
     if (checkAndSetPendingOperation(METHOD_DISCONNECT, response)) {
       return;
     }

     Auth.GoogleSignInApi.revokeAccess(googleApiClient)
         .setResultCallback(
             new ResultCallback<Status>() {
               @Override
               public void onResult(Status status) {
                 // TODO(tvolkert): communicate status back to user
                 finishOperation(EMPTY_SUCCESS_JSON);
               }
             });
   }

   /**
    * Invoked when the GMS client has successfully connected to the GMS server. This signals that
    * this listener is properly initialized.
    */
   @Override
   public void onConnected(Bundle connectionHint) {
     // We can get reconnected if, e.g. the activity is paused and resumed.
     if (pendingOperation != null && pendingOperation.method.equals(METHOD_INIT)) {
       finishOperation(EMPTY_SUCCESS_JSON);
     }
   }

   /**
    * Invoked when the GMS client was unable to connect to the GMS server, either because of an error
    * the user was unable to resolve, or because the user canceled the resolution (e.g. cancelling a
    * dialog instructing them to upgrade Google Play Services). This signals that we were unable to
    * properly initialize this listener.
    */
   @Override
   public void onConnectionFailed(@NonNull ConnectionResult result) {
     // We can attempt to reconnect if, e.g. the activity is paused and resumed.
     if (pendingOperation != null && pendingOperation.method.equals(METHOD_INIT)) {
       finishOperation(getFailureResponse(ERROR_REASON_CONNECTION_FAILED, result.toString()));
     }
   }

   @Override
   public void onConnectionSuspended(int cause) {
     // TODO(jackson): implement
     Log.w(TAG, "The GMS server connection has been suspended (" + cause + ")");
   }

   public void onActivityResult(int requestCode, int resultCode, Intent data) {
     if (requestCode != this.requestCode) {
       // We're only interested in the "sign in" activity result
       return;
     }

     if (pendingOperation == null || !pendingOperation.method.equals(METHOD_SIGN_IN)) {
       Log.w(TAG, "Unexpected activity result; sign-in not in progress");
       return;
     }

     if (resultCode != Activity.RESULT_OK) {
       finishOperation(getFailureResponse(ERROR_REASON_CANCELED, String.valueOf(resultCode)));
       return;
     }

     onSignInResult(Auth.GoogleSignInApi.getSignInResultFromIntent(data));
   }

   private void onSignInResult(GoogleSignInResult result) {
     if (result.isSuccess()) {
       finishOperation(getSignInResponse(result.getSignInAccount()));
     } else {
       finishOperation(getFailureResponse(ERROR_REASON_STATUS, result.getStatus().toString()));
     }
   }

   private static String getSignInResponse(GoogleSignInAccount account) {
     Uri photoUrl = account.getPhotoUrl();
     try {
       return new JSONObject()
           .put("success", true)
           .put(
               "signInAccount",
               new JSONObject()
                   .put("displayName", account.getDisplayName())
                   .put("email", account.getEmail())
                   .put("id", account.getId())
                   .put("photoUrl", photoUrl != null ? photoUrl.toString() : null))
           .toString();
     } catch (JSONException e) {
       return getFailureResponse(ERROR_REASON_EXCEPTION, e.getMessage());
     }
   }

   private static String getTokenResponse(String token) {
     try {
       return new JSONObject().put("success", true).put("token", token).toString();
     } catch (JSONException e) {
       return getFailureResponse(ERROR_REASON_EXCEPTION, e.getMessage());
     }
   }

   private static String getFailureResponse(String reason, String detail) {
     try {
       return new JSONObject()
           .put("success", false)
           .put("reason", reason)
           .put("detail", detail)
           .toString();
     } catch (JSONException e) {
       Log.e(TAG, "JSON exception", e);
       return String.format(
           "{\"success\":false,\"reason\":\"%s\",\"detail\":\"%s\"}",
           ERROR_REASON_EXCEPTION, JSONObject.quote(e.getMessage()));
     }
   }

   private void finishOperation(String message) {
     for (MessageResponse response : pendingOperation.responseQueue) {
       response.send(message);
     }
     pendingOperation = null;
   }
 }
