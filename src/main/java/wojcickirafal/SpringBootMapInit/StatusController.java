package wojcickirafal.SpringBootMapInit;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
public class StatusController {

    @GetMapping("/health")
    public Map<String, String> health() {
        return Map.of("status", "UP");
    }

    @GetMapping("/version")
    public Map<String, String> version() {
        String implementationVersion = SpringbootMapInitApplication.class.getPackage().getImplementationVersion();
        return Map.of("version", implementationVersion != null ? implementationVersion : "dev");
    }
}
