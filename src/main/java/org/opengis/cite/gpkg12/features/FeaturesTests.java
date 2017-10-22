package org.opengis.cite.gpkg12.features;

import static org.testng.Assert.assertTrue;

import java.io.IOException;
import java.io.InputStream;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Iterator;

import org.opengis.cite.gpkg12.CommonFixture;
import org.opengis.cite.gpkg12.ErrorMessage;
import org.opengis.cite.gpkg12.ErrorMessageKeys;
import org.opengis.cite.gpkg12.GPKG12;
import org.testng.Assert;
import org.testng.annotations.BeforeClass;
import org.testng.annotations.Test;

/**
 * Defines test methods that apply to descriptive information about a
 * GeoPackage's content as it pertains to features.
 *
 * <p style="margin-bottom: 0.5em">
 * <strong>Sources</strong>
 * </p>
 * <ul>
 * <li><a href="http://www.geopackage.org/spec/#features" target= "_blank">
 * GeoPackage Encoding Standard - 2.1 Features</a> (OGC 12-128r13)</li>
 * </ul>
 *
 * @author Jeff Yutzler
 */
public class FeaturesTests extends CommonFixture {
	/**
	 * Sets up variables used across methods
	 *
	 * @throws SQLException
	 *             if there is a database error
	 */
	@BeforeClass
	public void setUp() throws SQLException {
		try (
				final Statement statement = this.databaseConnection.createStatement();
				final ResultSet resultSet = statement.executeQuery("SELECT table_name FROM gpkg_contents WHERE data_type = 'features';");
				) {
			while (resultSet.next()) {
				this.featureTableNames.add(resultSet.getString(1));
			}
		}

		Assert.assertTrue(!this.featureTableNames.isEmpty(), ErrorMessage.format(ErrorMessageKeys.CONFORMANCE_CLASS_NOT_USED, getTestName()));
	}

	/**
	 * A GeoPackage MAY contain tables or updateable views containing vector 
	 * features. Every such feature table or view in a GeoPackage SHALL have 
	 * a column with column type INTEGER and PRIMARY KEY AUTOINCREMENT column 
	 * constraints per EXAMPLE : Sample Feature Table or View Definition and 
	 * sample_feature_table Table Definition SQL (Informative).
	 *
	 * Test case
	 * {@code /opt/features/vector_features/data/feature_table_integer_primary_key}
	 *
	 * @see <a href="requirement_feature_integer_pk" target= "_blank">Vector
	 *      Features User Data Tables - Requirement 29</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 29")
	public void featureTableIntegerPrimaryKey() throws SQLException {
		for (final String tableName : this.featureTableNames) {
			try (
					final Statement statement = this.databaseConnection.createStatement();
					// 1
					final ResultSet resultSet = statement.executeQuery(String.format("PRAGMA table_info(%s);", tableName));
					) {
				// 2
				assertTrue(resultSet.next(),
						ErrorMessage.format(ErrorMessageKeys.MISSING_TABLE, tableName));				
			}

			// 3
			checkPrimaryKey(tableName, getPrimaryKeyColumn(tableName));
		}
	}


	/**
	 * Test case
	 * {@code /opt/features/geometry_encoding/data/blob} and 
	 * {@code /opt/features/geometry_encoding/data/core_types_existing_sparse_data}
	 * This test will also fail if the primary key is missing since that makes it difficult
	 * to isolate which ro
	 *
	 * @see <a href="_requirement-19" target= "_blank">Vector
	 *      Features BLOB Format - Requirement 19 and 20</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirements 19, 20")
	public void featureGeometryEncodingTableBlob() throws SQLException {
		try (
				// 1
				final Statement statement1 = this.databaseConnection.createStatement();

				final ResultSet resultSet1 = statement1.executeQuery("SELECT table_name AS tn, column_name AS cn FROM gpkg_geometry_columns WHERE table_name IN (SELECT table_name FROM gpkg_contents WHERE data_type = 'features');");
				) {
			// 2
			while (resultSet1.next()){
				final String cn = resultSet1.getString("cn");
				final String tn = resultSet1.getString("tn");
				String pkColumn;
				try {
					pkColumn = getPrimaryKeyColumn(tn);
				} catch (AssertionError exc) {
					// If we don't find a primary key, just use the rowid;
					pkColumn = "rowid";
				}

				try (
						final Statement statement3 = this.databaseConnection.createStatement();
						// 3a
						final ResultSet resultSet3 = statement3.executeQuery(String.format("SELECT %s, %s FROM %s;", cn, pkColumn, tn));
						) {
					// 3b
					while (resultSet3.next()){
						final int pk = resultSet3.getInt(pkColumn);
						final byte[] sgbpb = new byte[4];

						// 3c
						try (InputStream sgpb = resultSet3.getBinaryStream(cn)) {
							sgpb.read(sgbpb);
						} catch (NullPointerException npe) {
							// This exception will be thrown if the geometry BLOB is NULL
							continue;
						}
						catch (IOException e) {
							// TODO Auto-generated catch block
							assertTrue(false, ErrorMessage.format(ErrorMessageKeys.FEATURES_BINARY_INVALID, tn, pk, "Couldn't read WKB prefix"));
						}

						// 3ci
						final byte[] gp = Arrays.copyOfRange(sgbpb, 0, 2);
						assertTrue(Arrays.equals(gp, GPKG12.BINARY_GP), ErrorMessage.format(ErrorMessageKeys.FEATURES_BINARY_INVALID, tn, pk, "First two bytes of WKB are wrong."));

						// 3cii
						assertTrue(sgbpb[2] == 0, ErrorMessage.format(ErrorMessageKeys.FEATURES_BINARY_INVALID, tn, pk, "Third byte of WKB must be 0."));

						// 3ciii
						assertTrue((sgbpb[3] & 0b00100000) == 0, ErrorMessage.format(ErrorMessageKeys.FEATURES_BINARY_INVALID, tn, pk, "Sixth bit of byte 4 of WKB must be 0."));

						// 3civ
						final int envelope = (sgbpb[3] & 0b00001110) >> 1;
						assertTrue(envelope <= 4, ErrorMessage.format(ErrorMessageKeys.FEATURES_BINARY_INVALID, tn, pk, "Envelope type of WKB (byte 4) is invalid."));

						// TODO: 3cv 
					}					
				}
			}
		}
	}

	/**
	 * Test case
	 * {@code /opt/features/geometry_columns/data/table_def}
	 *
	 * @see <a href="_requirement-21" target= "_blank">Vector
	 *      Features Geometry Columns Table - Requirement 21</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 21")
	public void featureGeometryColumnsTableDef() throws SQLException {
		try (
				// 1
				final Statement statement = this.databaseConnection.createStatement();

				final ResultSet resultSet = statement.executeQuery("PRAGMA table_info('gpkg_geometry_columns');");
				) {

			// 2
			int passFlag = 0;
			final int flagMask = 0b00111111;

			while (resultSet.next()) {
				// 3
				final String name = resultSet.getString("name");
				if ("geometry_type_name".equals(name)){
					assertTrue("TEXT".equals(resultSet.getString("type")), ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID);
					assertTrue(resultSet.getInt("notnull") == 1, ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID);
					assertTrue(resultSet.getInt("pk") == 0, ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID);
					passFlag |= 1;
				} else if ("table_name".equals(name)){
					assertTrue("TEXT".equals(resultSet.getString("type")), ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID);
					assertTrue(resultSet.getInt("notnull") == 1, ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID);
					assertTrue(resultSet.getInt("pk") == 1, ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID);
					passFlag |= (1 << 1);
				} else if ("m".equals(name)){
					assertTrue("TINYINT".equals(resultSet.getString("type")), ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID);
					assertTrue(resultSet.getInt("notnull") == 1, ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID);
					assertTrue(resultSet.getInt("pk") == 0, ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID);
					passFlag |= (1 << 2);
				} else if ("z".equals(name)){
					assertTrue("TINYINT".equals(resultSet.getString("type")), ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID);
					assertTrue(resultSet.getInt("notnull") == 1, ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID);
					assertTrue(resultSet.getInt("pk") == 0, ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID);
					passFlag |= (1 << 3);
				} else if ("srs_id".equals(name)){
					assertTrue("INTEGER".equals(resultSet.getString("type")), ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID);
					assertTrue(resultSet.getInt("notnull") == 1, ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID);
					assertTrue(resultSet.getInt("pk") == 0, ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID);
					passFlag |= (1 << 4);
				} else if ("column_name".equals(name)){
					assertTrue("TEXT".equals(resultSet.getString("type")), ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID);
					assertTrue(resultSet.getInt("notnull") == 1, ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID);
					assertTrue(resultSet.getInt("pk") == 2, ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID);
					passFlag |= (1 << 5);
				}
			} 
			assertTrue((passFlag & flagMask) == flagMask, ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID);			
		}
	}

	/**
	 * Test case
	 * {@code /opt/features/geometry_columns/data/data_values_geometry_columns}
	 *
	 * @see <a href="_requirement-22" target= "_blank">Vector
	 *      Features Geometry Columns Table - Requirement 22</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 22")
	public void featureGeometryColumnsDataValues() throws SQLException {
		try (		
				// 1
				final Statement statement = this.databaseConnection.createStatement();

				final ResultSet resultSet = statement.executeQuery("SELECT table_name FROM gpkg_contents WHERE data_type = 'features';");
				) {
			// 2
			if (resultSet.next()){
				try (
						// 3
						final Statement statement2 = this.databaseConnection.createStatement();

						final ResultSet resultSet2 = statement2.executeQuery("SELECT table_name FROM gpkg_contents WHERE data_type = 'features' AND table_name NOT IN (SELECT table_name FROM gpkg_geometry_columns);");
						) {
					assertTrue(!resultSet2.next(), ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_MISMATCH);
				}
			}			
		}
	}

	/**
	 * Test case
	 * {@code /opt/features/geometry_columns/data/data_values_table_name} and
	 * {@code /opt/features/geometry_columns/data/data_values_srs_id}
	 *
	 * @see <a href="_requirement-23" target= "_blank">Vector
	 *      Features Geometry Columns Table - Requirement 23</a>
	 * and  <a href="_requirement-26" target= "_blank">Vector
	 *      Features Geometry Columns SRS ID - Requirement 26</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 23, 26")
	public void featureGeometryColumnsDataValuesTableName() throws SQLException {
		try (
				// 1
				final Statement statement = this.databaseConnection.createStatement();

				final ResultSet resultSet = statement.executeQuery("PRAGMA foreign_key_list('gpkg_geometry_columns');");
				) {
			boolean foundContents = false;
			boolean foundSpatialRefSys = false;

			// 2
			while (resultSet.next()){
				// 3
				final String table = resultSet.getString("table");
				if ("gpkg_spatial_ref_sys".equals(table)){
					if ("srs_id".equals(resultSet.getString("from")) && "srs_id".equals(resultSet.getString("to"))){
						foundSpatialRefSys = true;
					}
				} else if ("gpkg_contents".equals(table)){
					if ("table_name".equals(resultSet.getString("from")) && "table_name".equals(resultSet.getString("to"))){
						foundContents = true;
					}
				}
			}
			assertTrue(foundContents && foundSpatialRefSys, ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_NO_FK);
		}
	}

	/**
	 * Test case
	 * {@code /opt/features/geometry_columns/data/data_values_column_name}
	 *
	 * @see <a href="_requirement-24" target= "_blank">Vector
	 *      Features Geometry Columns Column - Requirement 24</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 24")
	public void featureGeometryColumnsDataValuesColumnName() throws SQLException {
		try (
				// 1
				final Statement statement = this.databaseConnection.createStatement();

				final ResultSet resultSet = statement.executeQuery("SELECT table_name, column_name FROM gpkg_geometry_columns;");
				) {
			// 2
			while (resultSet.next()){
				final String tableName = resultSet.getString("table_name");
				final String columnName = resultSet.getString("column_name");

				try (
						final Statement statement2 = this.databaseConnection.createStatement();

						final ResultSet resultSet2 = statement2.executeQuery(String.format("PRAGMA table_info('%s');", tableName));
						) {
					boolean foundMatch = false;

					while (resultSet2.next()) {
						if (resultSet2.getString("name").equals(columnName)){
							foundMatch = true;
							break;
						}
					}

					assertTrue(foundMatch, ErrorMessage.format(ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID_COL, tableName, columnName));
				}
			}	
		}
	}

	/**
	 * Test case
	 * {@code /opt/features/geometry_columns/data/data_values_geometry_type_name}
	 *
	 * @see <a href="_requirement-25" target= "_blank">Vector
	 *      Features Geometry Columns Geometry Type - Requirement 25</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 25")
	public void featureGeometryColumnsDataValuesGeometryType() throws SQLException {
		try (
				// 1
				final Statement statement = this.databaseConnection.createStatement();

				final ResultSet resultSet = statement.executeQuery("SELECT table_name, column_name, geometry_type_name FROM gpkg_geometry_columns");
				) {
			// 2
			while (resultSet.next()){
				// 3
				final String geometryTypeName = resultSet.getString("geometry_type_name");
				final String tableName = resultSet.getString("table_name");
				final String columnName = resultSet.getString("column_name");

				boolean pass = false;

				if (getGeopackageVersion().equals(GeoPackageVersion.V120)){
					pass = ALLOWED_GEOMETRY_TYPES.contains(geometryTypeName);
				} else {
					final Iterator<String> iterator = ALLOWED_GEOMETRY_TYPES.iterator();
					while(iterator.hasNext()){
						if (geometryTypeName.equalsIgnoreCase(iterator.next())){
							pass = true;
							break;
						}
					}
				}

				if (!pass) {
					pass = isExtendedType(tableName, columnName);
				}

				assertTrue(pass, ErrorMessage.format(ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID_GEOM, geometryTypeName, tableName));
			}
		}
	}

	/**
	 * Test case
	 * {@code /opt/features/geometry_columns/data/data_values_z}
	 *
	 * @see <a href="_requirement-27" target= "_blank">Vector
	 *      Features Geometry Columns Z - Requirement 27</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 27")
	public void featureGeometryColumnsDataValuesZ() throws SQLException {
		try (
				// 1
				final Statement statement = this.databaseConnection.createStatement();

				final ResultSet resultSet = statement.executeQuery("SELECT z FROM gpkg_geometry_columns");
				) {
			// 2
			if (resultSet.next()){
				try (
						// 3
						final Statement statement2 = this.databaseConnection.createStatement();

						final ResultSet resultSet2 = statement2.executeQuery("SELECT z FROM gpkg_geometry_columns WHERE z NOT IN (0,1,2)");
						) {
					if(resultSet2.next()){
						assertTrue(false, ErrorMessage.format(ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID_Z, resultSet2.getInt("z")));
					}
				}
			}
		}
	}

	/**
	 * Test case
	 * {@code /opt/features/geometry_columns/data/data_values_m}
	 *
	 * @see <a href="_requirement-28" target= "_blank">Vector
	 *      Features Geometry Columns M - Requirement 28</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 28")
	public void featureGeometryColumnsDataValuesM() throws SQLException {
		try (
				// 1
				final Statement statement = this.databaseConnection.createStatement();

				final ResultSet resultSet = statement.executeQuery("SELECT m FROM gpkg_geometry_columns");
				) {
			// 2
			if (resultSet.next()){
				try (
						// 3
						final Statement statement2 = this.databaseConnection.createStatement();

						final ResultSet resultSet2 = statement2.executeQuery("SELECT m FROM gpkg_geometry_columns WHERE m NOT IN (0,1,2)");
						) {
					if(resultSet2.next()){
						assertTrue(false, ErrorMessage.format(ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID_M, resultSet2.getInt("m")));
					}
				}
			}
		}
	}

	/**
	 * Test case
	 * {@code /opt/features/vector_features/data/feature_table_one_geometry_column}
	 *
	 * @see <a href="_requirement-30" target= "_blank">Vector
	 *      Features One Geometry Column - Requirement 30</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 30")
	public void featureTableOneGeometryColumn() throws SQLException {
		try (		
				// 1
				final Statement statement = this.databaseConnection.createStatement();

				final ResultSet resultSet = statement.executeQuery("SELECT table_name FROM gpkg_contents WHERE data_type='features'");
				) {
			// 2
			while (resultSet.next()){
				// 3
				final String tableName = resultSet.getString("table_name");
				try (
						final Statement statement2 = this.databaseConnection.createStatement();

						final ResultSet resultSet2 = statement2.executeQuery(String.format("SELECT count(*) FROM gpkg_geometry_columns WHERE table_name = '%s'", tableName));
						) {
					resultSet2.next();
					assertTrue(resultSet2.getInt(1) == 1, ErrorMessageKeys.FEATURES_ONE_GEOMETRY_COLUMN);
				}
			}
		}
	}

	/**
	 * Test case
	 * {@code /opt/features/vector_features/data/feature_table_geometry_column_type}
	 *
	 * @see <a href="_requirement-31" target= "_blank">Vector
	 *      Features Geometry Column Type - Requirement 31</a>
	 *
	 * @throws SQLException
	 *             If an SQL query causes an error
	 */
	@Test(description = "See OGC 12-128r13: Requirement 31")
	public void featureTableGeometryColumnType() throws SQLException {
		// We're just going to skip this test on older GeoPackages and hope for the best.
		if (getGeopackageVersion().equals(GeoPackageVersion.V120)){
			try (
					// 1
					final Statement statement = this.databaseConnection.createStatement();

					final ResultSet resultSet = statement.executeQuery("SELECT table_name, column_name, geometry_type_name FROM gpkg_geometry_columns WHERE table_name IN (SELECT table_name FROM gpkg_contents WHERE data_type = 'features')");
					) {
				// 2
				while (resultSet.next()){
					// 2a
					final String geometryTypeName = resultSet.getString("geometry_type_name");
					// This assertion being removed as per https://github.com/opengeospatial/geopackage/issues/347
					//				assertTrue(allowedGeometryTypes.contains(geometryTypeName), ErrorMessage.format(ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_INVALID_GEOM, geometryTypeName));

					//2b
					final String tableName = resultSet.getString("table_name");
					final String columnName = resultSet.getString("column_name");
					try (
							final Statement statement2 = this.databaseConnection.createStatement();

							final ResultSet resultSet2 = statement2.executeQuery(String.format("PRAGMA table_info('%s')", tableName));
							) {
						while (resultSet2.next()){
							if (columnName.equals(resultSet2.getString("name"))) {
								assertTrue(geometryTypeName.equals(resultSet2.getString("type")), ErrorMessageKeys.FEATURES_GEOMETRY_COLUMNS_MISMATCH);
								break;
							}
						}
					}
				}				
			}
		}
	}

	// TODO: Don't know how to test R32/33 as they require a spatial library

	private static final Collection<String> ALLOWED_GEOMETRY_TYPES = 
			Arrays.asList("GEOMETRY","POINT","LINESTRING","POLYGON","MULTIPOINT","MULTILINESTRING","MULTIPOLYGON","GEOMETRYCOLLECTION");
	protected static Collection<String> getAllowedGeometryTypes() {
		return ALLOWED_GEOMETRY_TYPES;
	}

	private final Collection<String> featureTableNames = new ArrayList<>();
}
