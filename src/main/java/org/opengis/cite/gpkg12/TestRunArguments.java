package org.opengis.cite.gpkg12;

import java.io.File;
import java.net.URI;
import java.util.ArrayList;
import java.util.List;

import com.beust.jcommander.Parameter;

/**
 * Declares supported command line arguments that are parsed using the
 * JCommander library. All arguments are optional. The default values are as
 * follows:
 * <ul>
 * <li>XML properties file: ${user.home}/test-run-props.xml</li>
 * <li>outputDir: ${user.home}</li>
 * </ul>
 *
 * <p>
 * <strong>Synopsis</strong>
 * </p>
 * 
 * <pre>
 * ets-${ets-code}-${version}-aio.jar [-o|--outputDir $TMPDIR] [test-run-props.xml]
 * </pre>
 */
public class TestRunArguments {

    @Parameter(description = "Properties file")
    private final List<String> xmlProps;

    @Parameter(names = { "-o", "--outputDir" }, description = "Output directory")
    private String outputDir;

    public TestRunArguments() {
        this.xmlProps = new ArrayList<>();
    }

    public File getPropertiesFile() {
        File fileRef;
        if (xmlProps.isEmpty()) {
            fileRef = new File(System.getProperty("user.home"), "test-run-props.xml");
        } else {
            String propsFile = xmlProps.get(0);
            fileRef = (propsFile.startsWith("file:")) ? new File(URI.create(propsFile)) : new File(propsFile);
        }
        return fileRef;
    }

    public String getOutputDir() {
        return (null != outputDir) ? outputDir : System.getProperty("user.home");
    }
}
