package wojcickirafal.SpringBootMapInit;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.io.IOException;
import java.util.List;


@Controller
public class MapController {

    private final Covid19Parser covid19Parser;

    public MapController(Covid19Parser covid19Parser) {
        this.covid19Parser = covid19Parser;
    }

    @GetMapping("/")
    @ResponseBody
    public List<Point> getPoints() throws IOException {
        return covid19Parser.getCovidData();
    }

    @GetMapping("/map")
    public String getMap(Model model) throws IOException {
        model.addAttribute("points", covid19Parser.getCovidData());
        return "map";
    }
}
