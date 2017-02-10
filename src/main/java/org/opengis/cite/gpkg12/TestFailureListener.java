package org.opengis.cite.gpkg12;

import org.testng.ITestResult;
import org.testng.TestListenerAdapter;

/**
 * A listener that augments a test result with diagnostic information in the
 * event that a test method failed. This information will appear in the XML
 * report when the test run is completed.
 */
public class TestFailureListener extends TestListenerAdapter {

    /**
     * Invoked each time a test method fails.
     *
     * @param result
     *            A description of a test result (with a fail verdict).
     */
    @Override
    public void onTestFailure(ITestResult result) {
        super.onTestFailure(result);
        // Implement behavior
    }

}
