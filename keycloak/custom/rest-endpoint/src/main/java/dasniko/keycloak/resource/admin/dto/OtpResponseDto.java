package dasniko.keycloak.resource.admin.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class OtpResponseDto {
		private String totpSecret;
		private String totpSecretEncoded;
		private String totpSecretQrCode;
}
