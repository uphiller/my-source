package dasniko.keycloak.resource.admin.dto;

import lombok.Data;


@Data
public class OtpRequestDto {

		private String totpSecret;
		private String totp;
}
