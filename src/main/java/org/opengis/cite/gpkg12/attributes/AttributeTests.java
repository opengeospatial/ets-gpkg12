package org.opengis.cite.gpkg12.attributes;

import static org.testng.Assert.assertTrue;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Collection;

import org.opengis.cite.gpkg12.CommonFixture;
import org.opengis.cite.gpkg12.ErrorMessage;
import org.opengis.cite.gpkg12.ErrorMessageKeys;
import org.testng.Assert;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;

/**
 * Defines test methods that verify a GeoPackage's content relating to
 * attributes.
 *
 * <p style="margin-bottom: 0.5em">
 * <strong>Sources</strong>
 * </p>
 * <ul>
 * <li><a href="http://www.geopackage.org/spec/#attributes" target= "_blank">
 * GeoPackage Encoding Standard - 2.4 Attributes</a> (OGC 12-128r13)</li>
 * </ul>
 *
 * @author Brad Hards
 */
public class AttributeTests extends CommonFixture {

    private final Collection<String> attributeTableNames = new ArrayList<>();

    /**
     * Shared setup.
     *
     * @throws SQLException if connection could not be established
     */
    @BeforeClass
    public void setUp() throws SQLException {
        try (
                final Statement statement = this.databaseConnection.createStatement();
                final ResultSet resultSet = statement.executeQuery("SELECT table_name FROM gpkg_contents WHERE data_type = 'attributes'");) {
            while (resultSet.next()) {
                attributeTableNames.add(resultSet.getString(1));
            }
        }

        Assert.assertTrue(!attributeTableNames.isEmpty(), ErrorMessage.format(ErrorMessageKeys.CONFORMANCE_CLASS_NOT_USED, getTestName()));
    }

    /**
     * A GeoPackage MAY contain tables or updatable views containing attribute
     * sets. Every such Attribute table or view in a GeoPackage SHALL have a
     * column with column type INTEGER and PRIMARY KEY AUTOINCREMENT column
     * constraints per GeoPackage Attributes Example Table or View Definition
     * and EXAMPLE: Attributes table Create Table SQL (Informative).
     *
     * See Attribute User Data Tables - Requirement 119 and
     * /opt/attributes/contents/data/attributes_row
     *
     * @throws SQLException If an SQL query causes an error
     */
    @Test(description = "See OGC 12-128r14: Requirement 119")
    public void attributeTableIntegerPrimaryKey() throws SQLException {
        for (final String tableName : attributeTableNames) {
            try (final Statement statement = databaseConnection.createStatement(); final ResultSet resultSet = statement.executeQuery(String.format("PRAGMA table_info(%s);", tableName));) {
                assertTrue(resultSet.next(), ErrorMessage.format(ErrorMessageKeys.MISSING_TABLE, tableName));
            }
            checkPrimaryKey(tableName, getPrimaryKeyColumn(tableName));
        }
    }
}
