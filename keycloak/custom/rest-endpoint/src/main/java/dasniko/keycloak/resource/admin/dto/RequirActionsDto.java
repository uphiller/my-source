package dasniko.keycloak.resource.admin.dto;

import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class RequirActionsDto {
		private String user_id;
		private List<String> actions;
}
