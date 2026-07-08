package wojcickirafal.SpringBootMapInit;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;
import java.util.Objects;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.BDDMockito.given;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.model;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.view;

@WebMvcTest(MapController.class)
class MapControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private Covid19Parser covid19Parser;

    @Test
    void returnsPointsAsJsonFromRootEndpoint() throws Exception {
        given(covid19Parser.getCovidData()).willReturn(List.of(new Point(1.25, 2.5, "12")));

        mockMvc.perform(get("/"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].lat").value(1.25))
                .andExpect(jsonPath("$[0].lon").value(2.5))
                .andExpect(jsonPath("$[0].text").value("12"));
    }

    @Test
    void addsPointsToModelForMapView() throws Exception {
        List<Point> points = List.of(new Point(51.0, 19.0, "99"));
        given(covid19Parser.getCovidData()).willReturn(points);

        var result = mockMvc.perform(get("/map"))
                .andExpect(status().isOk())
                .andExpect(view().name("map"))
                .andExpect(model().attributeExists("points"))
                .andReturn();

        Object modelPoints = Objects.requireNonNull(result.getModelAndView()).getModel().get("points");
        assertThat(modelPoints).isEqualTo(points);
    }
}
