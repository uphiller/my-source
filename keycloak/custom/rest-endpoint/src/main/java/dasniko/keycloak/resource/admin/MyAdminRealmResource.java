package dasniko.keycloak.resource.admin;

import dasniko.keycloak.resource.admin.dto.OtpRequestDto;
import dasniko.keycloak.resource.admin.dto.OtpResponseDto;
import dasniko.keycloak.resource.admin.dto.RequirActionsDto;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import lombok.RequiredArgsConstructor;
import org.keycloak.credential.CredentialModel;
import org.keycloak.models.KeycloakSession;
import org.keycloak.models.RealmModel;
import org.keycloak.models.UserModel;
import org.keycloak.models.credential.OTPCredentialModel;
import org.keycloak.models.utils.CredentialValidation;
import org.keycloak.models.utils.HmacOTP;
import org.keycloak.services.resources.admin.permissions.AdminPermissionEvaluator;
import org.keycloak.utils.CredentialHelper;
import org.keycloak.utils.TotpUtils;

import java.util.List;
import java.util.stream.Collectors;

@RequiredArgsConstructor
//@Path("/admin/realms/{realm}/" + MyAdminRealmResourceProvider.PROVIDER_ID)
public class MyAdminRealmResource{

	private final KeycloakSession session;
	private final RealmModel realm;
	private final AdminPermissionEvaluator auth;

	@GET
	@Path("/users/{email}/info")
	@Produces(MediaType.APPLICATION_JSON)
	public Response getListOfRequireAction(@PathParam("email") String email) {
		RealmModel realm = session.getContext().getRealm();
		UserModel user = session.users().getUserByEmail(realm, email);
		if(user == null){
			return Response.status(Response.Status.NOT_FOUND).build();
		} else {
			RequirActionsDto requirActionsDto = RequirActionsDto.builder().user_id(user.getId()).actions(user.getRequiredActionsStream().collect(Collectors.toList())).build();
			return Response.ok(requirActionsDto).build();
		}
	}

	@PUT
	@Path("/users/{id}/send-verify-email")
	@Produces(MediaType.APPLICATION_JSON)
	public Response putVerifyEmail(final @PathParam("id") String userId) {
		RealmModel realm = session.getContext().getRealm();
		UserModel user = session.users().getUserById(realm, userId);
		if(user == null){
			return Response.status(Response.Status.NOT_FOUND).build();
		} else {
			user.removeRequiredAction(UserModel.RequiredAction.VERIFY_EMAIL);
			user.setEmailVerified(true);
			return Response.status(Response.Status.NO_CONTENT).build();
		}
	}

	@GET
	@Path("/users/{id}/otp/qrcode")
	public Response generateOTPQRCode(final @PathParam("id") String id) {
		RealmModel realm = session.getContext().getRealm();
		UserModel user = session.users().getUserById(realm, id);
		if(user == null){
			return Response.status(Response.Status.NOT_FOUND).build();
		} else {
			String totpSecret = HmacOTP.generateSecret(20);
			String totpSecretEncoded = TotpUtils.encode(totpSecret);
			String totpSecretQrCode = TotpUtils.qrCode(totpSecret, realm, user);

			OtpResponseDto otpResponseDto = OtpResponseDto.builder()
				.totpSecret(totpSecret)
				.totpSecretEncoded(totpSecretEncoded)
				.totpSecretQrCode(String.format("data:image/png;base64,%s", totpSecretQrCode))
				.build();

			return Response.ok(otpResponseDto).build();
		}
	}

	@POST
	@Path("/users/{id}/otp")
	@Consumes(MediaType.APPLICATION_JSON)
	public Response updateOtp(final @PathParam("id") String id, OtpRequestDto request) {

		RealmModel realm = session.getContext().getRealm();
		UserModel user = session.users().getUserById(realm, id);
		if (user == null) {
			return Response.status(Response.Status.NOT_FOUND).build();
		} else {
			String userLabel = "otp";
			OTPCredentialModel credentialModel = OTPCredentialModel.createFromPolicy(session.getContext().getRealm(), request.getTotpSecret(), userLabel);

			if (CredentialValidation.validOTP(request.getTotp(), credentialModel, realm.getOTPPolicy().getLookAheadWindow())) {
				List<CredentialModel> credentialList = user.credentialManager().getStoredCredentialsByTypeStream("otp").collect(Collectors.toList());
				if(credentialList.size() > 0 ) {
					user.credentialManager().removeStoredCredentialById(credentialList.get(0).getId());
				}
				CredentialHelper.createOTPCredential(session, session.getContext().getRealm(), user, request.getTotpSecret(), credentialModel);
				user.removeRequiredAction(UserModel.RequiredAction.CONFIGURE_TOTP);
				return Response.status(Response.Status.NO_CONTENT).build();
			} else {
				return Response.status(Response.Status.BAD_REQUEST).build();
			}
		}
	}
}
