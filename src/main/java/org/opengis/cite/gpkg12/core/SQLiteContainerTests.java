package org.opengis.cite.gpkg12.core;

import static org.testng.Assert.assertEquals;
import static org.testng.Assert.assertTrue;
import static org.testng.AssertJUnit.fail;

import java.io.FileInputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import org.opengis.cite.gpkg12.CommonFixture;
import org.opengis.cite.gpkg12.ErrorMessage;
import org.opengis.cite.gpkg12.ErrorMessageKeys;
import org.opengis.cite.gpkg12.GPKG12;
import org.testng.annotations.Test;

/**
 * Defines test methods that apply to an SQLite database file. The GeoPackage
 * standard defines a SQL database schema designed for use with the SQLite
 * software library.
 *
 * <p style="margin-bottom: 0.5em">
 * <strong>Sources</strong>
 * </p>
 * <ul>
 * <li><a href="http://www.geopackage.org/spec/#_sqlite_container" target=
 * "_blank">GeoPackage Encoding Standard - SQLite Container</a> (OGC 12-128r12)
 * </li>
 * <li><a href="http://www.sqlite.org/fileformat2.html" target= "_blank">SQLite
 * Database File Format</a></li>
 * </ul>
 *
 * @author Richard Martell
 * @author Luke Lambert
 */
public class SQLiteContainerTests extends CommonFixture {

	/**
	 * A GeoPackage shall be a SQLite database file using version 3 of the
	 * SQLite file format. The first 16 bytes of a GeoPackage must contain the
	 * (UTF-8/ASCII) string "SQLite format 3", including the terminating NULL
	 * character.
	 *
	 * @throws IOException
	 *             If an I/O error occurs while trying to read the data file.
	 *
	 * @see <a href="http://www.geopackage.org/spec/#_requirement-1" target=
	 *      "_blank">File Format - Requirement 1</a>
	 */
	@Test(description = "See OGC 12-128r12: Requirement 1")
	public void fileHeaderString() throws IOException {
		final byte[] headerString = new byte[GPKG12.SQLITE_MAGIC_HEADER.length];
		try (FileInputStream fileInputStream = new FileInputStream(this.gpkgFile)) {
			fileInputStream.read(headerString);
		}
		assertTrue(Arrays.equals(headerString, GPKG12.SQLITE_MAGIC_HEADER), ErrorMessage
				.format(ErrorMessageKeys.INVALID_HEADER_STR, new String(headerString, StandardCharsets.US_ASCII)));
	}

	/**
	 * A GeoPackage SHALL contain a value of 0x47504B47 ("GPKG" in ASCII) in 
	 * the "application_id" field of the SQLite database header to indicate 
	 * that it is a GeoPackage. A GeoPackage SHALL contain an appropriate 
	 * value in "user_version" field of the SQLite database header to 
	 * indicate its version. The value SHALL be in integer with a major 
	 * version, two-digit minor version, and two-digit bug-fix. For 
	 * GeoPackage Version 1.2 this value is 0x000027D8 (the hexadecimal value 
	 * for 10200). 
	 *
	 * @throws IOException
	 *             If an I/O error occurs while trying to read the data file.
	 *             
	 * @throws SQLException
	 *             If an SQL query causes an error
	 *
	 * @see <a href="http://www.geopackage.org/spec/#_requirement-2" target=
	 *      "_blank">File Format - Requirement 2</a>
	 * @see <a href=
	 *      "http://www.sqlite.org/src/artifact?ci=trunk&filename=magic.txt"
	 *      target= "_blank">Assigned application IDs</a>
	 */
	@Test(description = "See OGC 12-128r12: Requirement 2")
	public void applicationID() throws IOException, SQLException {
		// Note: Most of this is actually handled in CommonFixture::setupVersion()
		final GeoPackageVersion version = getGeopackageVersion();
		assertTrue(Arrays.asList(getAllowedVersions()).contains(version),
				ErrorMessage.format(ErrorMessageKeys.UNKNOWN_APP_ID));
		if (version.equals(GeoPackageVersion.V120)){
			try (
					final Statement statement = this.databaseConnection.createStatement();
					// 4a
					final ResultSet resultSet = statement.executeQuery("PRAGMA user_version");
					) {
				final int versionNumber;
				final String versionStr;
				if (resultSet.next()) {
					versionStr = resultSet.getString(1);
					versionNumber = Integer.parseInt(versionStr);
				} else {
					versionNumber = 0;
					versionStr = "";
				}

				// 4b
				assertTrue(versionNumber >= 10200, ErrorMessage.format(ErrorMessageKeys.UNKNOWN_APP_ID, versionStr));
			}
		}
	}

	/**
	 * A GeoPackage shall have the file extension name ".gpkg".
	 *
	 * @see <a href="http://www.geopackage.org/spec/#_requirement-3" target=
	 *      "_blank">File Extension Name - Requirement 3</a>
	 */
	@Test(description = "See OGC 12-128r12: Requirement 3")
	public void filenameExtension() {
		final String fileName = this.gpkgFile.getName();
		final String suffix = fileName.substring(fileName.lastIndexOf('.'));
		assertEquals(suffix, GPKG12.GPKG_FILENAME_SUFFIX,
				ErrorMessage.format(ErrorMessageKeys.INVALID_SUFFIX, suffix));
	}

	/**
	 * A GeoPackage shall only contain data elements, SQL constructs and
	 * GeoPackage extensions with the "gpkg" author name specified in this
	 * encoding standard.
	 *
	 * @throws SQLException on any error
	 * @see <a href="http://www.geopackage.org/spec/#_requirement-4" target=
	 *      "_blank">File Contents - Requirement 4</a>
	 */
	@Test(description = "See OGC 12-128r12: Requirement 4")
	public void fileContents() throws SQLException
	{
		// 1

		try (
				final Statement statement1 = this.databaseConnection.createStatement();
				final ResultSet resultSet1 = statement1.executeQuery("SELECT COUNT(*) FROM gpkg_extensions;");
				) {
			if(resultSet1.getInt(1) > 0){
				// NOOP: this is an Extended GeoPackage so the test does not apply
				return;
			}
		} catch (SQLException e1) {
			// NOOP: this is a GeoPackage with no extensions
		}

		final Iterator<String> iterator = SQLiteContainerTests.CoreTables.keySet().iterator();
		while (iterator.hasNext()) {
			final String tableName = iterator.next();
			try (				
					final Statement statement2 = this.databaseConnection.createStatement();
					final ResultSet resultSet2 = statement2.executeQuery(String.format("PRAGMA table_info(%s)", tableName));
					){
				while (resultSet2.next()){
					final String columnName = resultSet2.getString("name");
					assertTrue(SQLiteContainerTests.CoreTables.get(tableName).contains(columnName), 
							ErrorMessage.format(ErrorMessageKeys.UNEXPECTED_COLUMN, columnName, tableName));
				}
			} catch (SQLException e2) {
				// NOOP: This table doesn't exist, which may be allowed.
				// If it isn't, some other test will catch it.
			}
		}

		try (
				// 1
				final Statement statement3 = this.databaseConnection.createStatement();

				final ResultSet resultSet3 = statement3.executeQuery("SELECT DISTINCT data_type FROM gpkg_contents;");
				) {
			// 2
			while (resultSet3.next()){
				final String dataType = resultSet3.getString("data_type");
				assertTrue(SQLiteContainerTests.CoreDataTypes.contains(dataType),
						ErrorMessage.format(ErrorMessageKeys.INVALID_DATA_TYPE, dataType, "gpkg_contents"));
			}
		}
	}

	/**
	 * The SQLite PRAGMA integrity_check SQL command SHALL return "ok" for a
	 * GeoPackage file.
	 *
	 * @see <a href="http://www.geopackage.org/spec/#_requirement-6" target=
	 *      "_blank">File Integrity - Requirement 6</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r12: Requirement 6")
	public void pragmaIntegrityCheck() throws SQLException
	{
		try(final Statement statement = this.databaseConnection.createStatement();
				final ResultSet resultSet = statement.executeQuery("PRAGMA integrity_check;"))
		{
			resultSet.next();

			assertEquals(resultSet.getString("integrity_check").toLowerCase(),
					GPKG12.PRAGMA_INTEGRITY_CHECK,
					ErrorMessage.format(ErrorMessageKeys.PRAGMA_INTEGRITY_CHECK_NOT_OK));
		}
	}

	/**
	 * The SQLite PRAGMA foreign_key_check SQL with no parameter value SHALL
	 * return an empty result set indicating no invalid foreign key values for
	 * a GeoPackage file.
	 *
	 * @see <a href="http://www.geopackage.org/spec/#_requirement-7" target=
	 *      "_blank">File Integrity - Requirement 7</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r12: Requirement 7")
	public void foreignKeyCheck() throws SQLException
	{
		try(final Statement statement = this.databaseConnection.createStatement();
				final ResultSet resultSet = statement.executeQuery("PRAGMA foreign_key_check;"))
		{
			assertTrue(!resultSet.next(),
					ErrorMessage.format(ErrorMessageKeys.INVALID_FOREIGN_KEY));
		}
	}

	/**
	 * A GeoPackage SQLite Configuration SHALL provide SQL access to
	 * GeoPackage contents via software APIs.
	 *
	 * @see <a href="http://www.geopackage.org/spec/#_requirement-8" target=
	 *      "_blank">Structured Query Language (SQL) - Requirement 8</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r12: Requirement 8")
	public void sqlCheck() throws SQLException
	{
		try(final Statement stmt   = this.databaseConnection.createStatement();
				final ResultSet result = stmt.executeQuery("SELECT * FROM sqlite_master;"))
		{
			// If the statement can execute it has implemented the SQLite SQL API interface
			return;
		}
		catch(final SQLException ignored)
		{
			// fall through to failure
		}

		fail(ErrorMessage.format(ErrorMessageKeys.NO_SQL_ACCESS));
	}
	private static final Set<String> CoreDataTypes = new HashSet<String>();
	private static final Map<String, Set<String>> CoreTables = new HashMap<String, Set<String>>();
	static {
		final Set<String> contentsColumns = new HashSet<String>();
		contentsColumns.add("table_name");
		contentsColumns.add("data_type");
		contentsColumns.add("identifier");
		contentsColumns.add("description");
		contentsColumns.add("last_change");
		contentsColumns.add("min_x");
		contentsColumns.add("min_y");
		contentsColumns.add("max_x");
		contentsColumns.add("max_y");
		contentsColumns.add("srs_id");
		CoreTables.put("gpkg_contents", contentsColumns);
		final Set<String> srsColumns = new HashSet<String>();
		srsColumns.add("srs_name");
		srsColumns.add("srs_id");
		srsColumns.add("organization");
		srsColumns.add("description");
		srsColumns.add("organization_coordsys_id");
		srsColumns.add("definition");
		CoreTables.put("gpkg_spatial_ref_sys", srsColumns);
		final Set<String> geometryColumns = new HashSet<String>();
		geometryColumns.add("table_name");
		geometryColumns.add("column_name");
		geometryColumns.add("geometry_type_name");
		geometryColumns.add("srs_id");
		geometryColumns.add("z");
		geometryColumns.add("m");
		CoreTables.put("gpkg_geometry_columns", geometryColumns);
		final Set<String> tileMatrixSetColumns = new HashSet<String>();
		tileMatrixSetColumns.add("table_name");
		tileMatrixSetColumns.add("srs_id");
		tileMatrixSetColumns.add("min_x");
		tileMatrixSetColumns.add("min_y");
		tileMatrixSetColumns.add("max_x");
		tileMatrixSetColumns.add("max_y");
		CoreTables.put("gpkg_tile_matrix_set", tileMatrixSetColumns);
		final Set<String> tileMatrixColumns = new HashSet<String>();
		tileMatrixColumns.add("table_name");
		tileMatrixColumns.add("zoom_level");
		tileMatrixColumns.add("matrix_width");
		tileMatrixColumns.add("matrix_height");
		tileMatrixColumns.add("tile_width");
		tileMatrixColumns.add("tile_height");
		tileMatrixColumns.add("pixel_x_size");
		tileMatrixColumns.add("pixel_y_size");
		CoreTables.put("gpkg_tile_matrix", tileMatrixColumns);
		final Set<String> extensionsColumns = new HashSet<String>();
		extensionsColumns.add("table_name");
		extensionsColumns.add("column_name");
		extensionsColumns.add("extension_name");
		extensionsColumns.add("definition");
		extensionsColumns.add("scope");
		CoreTables.put("gpkg_extensions", extensionsColumns);
		CoreDataTypes.add("tiles");
		CoreDataTypes.add("features");
		CoreDataTypes.add("attributes");
	}
}
