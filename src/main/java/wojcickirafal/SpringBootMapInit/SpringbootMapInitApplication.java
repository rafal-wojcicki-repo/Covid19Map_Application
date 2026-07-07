package wojcickirafal.SpringBootMapInit;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.event.EventListener;

import java.awt.Desktop;
import java.awt.GraphicsEnvironment;
import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;

@SpringBootApplication
public class SpringbootMapInitApplication {

    private static final Logger LOGGER = LoggerFactory.getLogger(SpringbootMapInitApplication.class);

    public static void main(String[] args) {
        SpringApplication.run(SpringbootMapInitApplication.class, args);
    }

    @EventListener(ApplicationReadyEvent.class)
    public void openMapOnStartup() {
        if (GraphicsEnvironment.isHeadless() || !Desktop.isDesktopSupported()) {
            LOGGER.info("Desktop browser is not available. Open http://localhost:8080/map manually.");
            return;
        }

        try {
            Desktop.getDesktop().browse(new URI("http://localhost:8080/map"));
        } catch (IOException | URISyntaxException e) {
            LOGGER.warn("Failed to open browser on http://localhost:8080/map", e);
        }
    }

}
