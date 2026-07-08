package wojcickirafal.SpringBootMapInit;

import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

class Covid19ParserTest {

    private final Covid19Parser covid19Parser = new Covid19Parser();

    @Test
    void parsesValidRowsAndDefaultsBlankCoordinates() throws IOException {
        String csv = "Province/State,Country/Region,Lat,Long,1/1/20,1/2/20\n" +
                ",CountryA,10.5,20.5,1,2\n" +
                ",CountryB,,,3,4\n" +
                ",CountryC,bad,30.0,5,6\n";

        List<Point> points = covid19Parser.parseCsv(csv);

        assertThat(points).hasSize(2);
        assertThat(points.get(0).getLat()).isEqualTo(10.5);
        assertThat(points.get(0).getLon()).isEqualTo(20.5);
        assertThat(points.get(0).getText()).isEqualTo("2");
        assertThat(points.get(1).getLat()).isEqualTo(0.0);
        assertThat(points.get(1).getLon()).isEqualTo(0.0);
        assertThat(points.get(1).getText()).isEqualTo("4");
    }
}
