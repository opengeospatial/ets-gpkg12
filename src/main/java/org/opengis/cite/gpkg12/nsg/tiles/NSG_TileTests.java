
package org.opengis.cite.gpkg12.nsg.tiles;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.MessageFormat;
import java.util.Collection;
import java.util.Iterator;
import java.util.LinkedList;
//import java.util.function.Function;
import java.util.stream.Collectors;
import javax.imageio.ImageIO;
import javax.imageio.ImageReader;
import javax.imageio.stream.ImageInputStream;
import org.opengis.cite.gpkg12.tiles.TileTests;
import org.testng.Assert;
import org.testng.annotations.Test;

public class NSG_TileTests extends TileTests
{
	final private int minZoom = 0;
	final private int maxZoom = 24;
	
	final private double tolerance = 1.0e-10;

	// ----------------------------------------------------	
	/*
	 * --- NSG Req 19: Data validity SHALL be assessed against data value constraints specified
	 * 				   in Table 26 below using a test suite. Data validity MAY be enforced by SQL triggers.
	 * 
	 *     --- 19-D:  Addresses Table 26 Rows 12-17 (regarding table "gpkg_tile_matrix")
	 */
	
	@Test(groups = { "NSG" }, description = "NSG Req 19-D (Data Validity: gpkg_tile_matrix)")
	public void NSG_DataValidity() throws SQLException
	{
		// --- test for:  Table 26; Row 17
		
		String queryStr = "SELECT table_name FROM gpkg_contents WHERE data_type=\'tiles\';";
		
		try (final Statement statement = this.databaseConnection.createStatement();
			 final ResultSet resultSet = statement.executeQuery(queryStr))
		{
			while (resultSet.next())
			{
				String _tabNam = resultSet.getString("table_name").trim();
				int _firstZoom = 999;
				int _lastZoom = -1;
				String tileQuery = "SELECT DISTINCT zoom_level FROM " + _tabNam + " ORDER BY zoom_level;";
		
				// --- test for:  Table 26; Row 12 & 17
				
				try (final Statement tileStatement = this.databaseConnection.createStatement();
					 final ResultSet tileResultSet = tileStatement.executeQuery(tileQuery))
				{		
					while (tileResultSet.next())
					{
						int _zoom = tileResultSet.getInt("zoom_level");
						_firstZoom = Math.min(_firstZoom, _zoom);
						_lastZoom  = Math.max(_lastZoom,  _zoom);
					}
					tileResultSet.close();
					tileStatement.close();

					Assert.assertTrue((_firstZoom >= this.minZoom ), 
										MessageFormat.format(
												"The " + _tabNam + " table contains an invalid minimum zoom_level: {0}, should be: {1}",
												Integer.toString(_firstZoom), 
												Integer.toString(this.minZoom) )
									);
					Assert.assertTrue((_lastZoom <= this.maxZoom), 
										MessageFormat.format(
												"The " + _tabNam + " table contains an invalid maximum zoom_level: {0}, should be: {1}",
												Integer.toString(_firstZoom), 
												Integer.toString(this.maxZoom) )
									);
				}
					
				tileQuery = "SELECT zoom_level, tile_width, tile_height, pixel_x_size, pixel_y_size FROM gpkg_tile_matrix WHERE table_name=\'" + _tabNam + "\' ORDER BY zoom_level;";
					
				try (final Statement tileStatement = this.databaseConnection.createStatement();
					 final ResultSet tileResultSet = tileStatement.executeQuery(tileQuery))
				{		
					boolean _firstFound = false;
					boolean _lastFound = false;
					double _pixelSzX = 0.0D;
					double _pixelSzY = 0.0D;
					double _delta = 0.0D;

					while (tileResultSet.next()) 
					{
						int _zoom       = tileResultSet.getInt("zoom_level");
						int _tileWidth  = tileResultSet.getInt("tile_width");
						int _tileHeight = tileResultSet.getInt("tile_height");
							
						double _lastPixelSzX = _pixelSzX;
						double _lastPixelSzY = _pixelSzY;
						_pixelSzX = tileResultSet.getDouble("pixel_x_size");
						_pixelSzY = tileResultSet.getDouble("pixel_y_size");
	
						// --- test for:  Table 26; Row 12 (again)
						
						Assert.assertTrue(((_zoom >= _firstZoom ) && (_zoom <= _lastZoom)),
											MessageFormat.format(
													"The gpkg_tile_matrix contains an invalid zoom_level: {0} for {1}, should be between {2} and {3}",
													Integer.toString(_zoom), 
													_tabNam,
													Integer.toString( _firstZoom),
													Integer.toString( _lastZoom) )
										);
						
						if (!_firstFound)
						{
							_firstFound = (_zoom == _firstZoom);
						}

						if (!_lastFound)
						{
							_lastFound = (_zoom == _lastZoom);
						}

						// --- test for:  Table 26; Row 13
						
						Assert.assertTrue((_tileWidth == 256 ),
												MessageFormat.format(
														"The gpkg_tile_matrix contains an invalid tile_width: {0} for {1}, should be 256",
														Integer.toString(_tileWidth),
														_tabNam )
											);

						// --- test for:  Table 26; Row 14
						
						Assert.assertTrue((_tileHeight == 256 ),
												MessageFormat.format(
														"The gpkg_tile_matrix contains an invalid tile_height: {0} for {1}, should be 256",
														Integer.toString(_tileHeight),	
														_tabNam )
											);

						// --- test for:  Table 26; Row 15
						
						_delta = Math.abs((_pixelSzX * 2.0D ) - _lastPixelSzX);
						Assert.assertTrue(((_zoom == _firstZoom ) || ( _delta < this.tolerance )),
												MessageFormat.format(
														"The gpkg_tile_matrix contains an invalid pixel_x_size: {0} for {1}",
														String.format("%.10f",_pixelSzX),
														_tabNam )
											);
						
						// --- test for:  Table 26; Row 16
						
						_delta = Math.abs((_pixelSzY * 2.0D ) - _lastPixelSzY);
						Assert.assertTrue(((_zoom == _firstZoom ) || ( _delta < this.tolerance )),
												MessageFormat.format(
														"The gpkg_tile_matrix contains an invalid pixel_y_size: {0} for {1}",
														String.format("%.10f",_pixelSzY), 
														_tabNam )
											);
					}
					tileResultSet.close();
					tileStatement.close();

					// --- test for:  Table 26; Row 12 & 17 (again)
					
					Assert.assertTrue(_firstFound,
										MessageFormat.format(
												"The gpkg_tile_matrix contains an invalid zoom_level: no zoom level 0 for {0}",
												_tabNam )
									);
					Assert.assertTrue(_lastFound,
										MessageFormat.format(
												"The gpkg_tile_matrix contains an invalid zoom_level: no max zoom level for {0}",
												_tabNam )
										);
				}
			}
			resultSet.close();
			statement.close();
		}
	}
					
	// ----------------------------------------------------	
	/*
	 * --- NSG Req 20: The gpkg_tile_matrix table SHALL contain tile_width and tile_height
	 * 				   column values of 256 for every table_name tile pyramid data table.
	 *
	 * --- NSG Req 21: Every tile_data tile in every table_name tile pyramid data table shall
	 * 				   have a width and height of 256 pixels.
	 * 
	 */

	@Test(groups = { "NSG" }, description = "NSG Req 20 & 21 (Tile widths and heights)")
	public void NSG_TileSizeTests() throws SQLException, IOException
	{
		// --- test Req 20
		
		String queryStr = "SELECT table_name, zoom_level, tile_width, tile_height FROM gpkg_tile_matrix "
				        + "WHERE NOT ((tile_width=256) AND (tile_height=256));";
		
		try (final Statement statement = this.databaseConnection.createStatement();
			 final ResultSet resultSet = statement.executeQuery(queryStr))
		{
			final Collection<String> tableNames = new LinkedList<>();
			
			while (resultSet.next()) 
			{
				String _tabNam = resultSet.getString("table_name");
				tableNames.add(_tabNam + ": (tile_width)"  + resultSet.getInt("tile_width") + 
							             ", (tile_height)" + resultSet.getInt("tile_height"));
			}
			resultSet.close();
			statement.close();
			
			Assert.assertTrue(tableNames.isEmpty(), 
								MessageFormat.format(
										"The gpkg_tile_matrix table contains invalid tile width/height values for tables: {0}",
										tableNames.stream().map(Object::toString).collect(Collectors.joining(", ")) )
							);
		}
		
		// --- test Req 21
		
		queryStr = "SELECT DISTINCT table_name FROM gpkg_tile_matrix;";
		
		try (final Statement statement = this.databaseConnection.createStatement();
			 final ResultSet resultSet = statement.executeQuery(queryStr))
		{
			while (resultSet.next()) 
			{
				String _tableNam = resultSet.getString("table_name");				
				String subQueryStr = "SELECT zoom_level, tile_column, tile_row, tile_data FROM " + _tableNam;
		
				try (final Statement subStatement = this.databaseConnection.createStatement();
					 final ResultSet subResultSet = subStatement.executeQuery(subQueryStr))
				{
					while (subResultSet.next()) 
					{
						byte[] image = subResultSet.getBytes("tile_data");
						ImageInputStream iis = ImageIO.createImageInputStream(new ByteArrayInputStream(image));
						Iterator readers = ImageIO.getImageReaders(iis);

						while (readers.hasNext())
						{
							ImageReader read = (ImageReader) readers.next();
							read.setInput(iis, true);
							int width = read.getWidth(0);
							int height = read.getHeight(0);
							
							Assert.assertTrue((width == 256),
												MessageFormat.format(
														"The pyramid data table (for {0}) contains a tile image (at zoom_level:  {1}, (col,row): {2},{3}) with an invalid tile_width: {4}",
														_tableNam,
														Integer.toString(subResultSet.getInt("zoom_level")),
														Integer.toString(subResultSet.getInt("tile_column")),
														Integer.toString(subResultSet.getInt("tile_row")),
														Integer.toString(width) )
											);
							Assert.assertTrue((height == 256),
												MessageFormat.format(
														"The pyramid data table (for {0}) contains a tile image (at zoom_level:  {1}, (col,row): {2},{3}) with an invalid tile_height: {4}",
														_tableNam,
														Integer.toString(subResultSet.getInt("zoom_level")),
														Integer.toString(subResultSet.getInt("tile_column")),
														Integer.toString(subResultSet.getInt("tile_row")),
														Integer.toString(height) )
											);
						}
					}
					subResultSet.close();
					subStatement.close();
				}
			}
			resultSet.close();
			statement.close();
		}		
	}
	
// ----------------------------------------------------	
/*
* --- NSG Req 22: The gpkg_tile_matrix table SHALL contain pixel_x_size and
* 				  pixel_y_size column values that differ by a factor of 2 between all adjacent zoom levels for
*				  each tile pyramid data table per OGC GeoPackage Clause 2.2.3. It SHALL NOT contain
*				  pixel sizes that vary by irregular intervals or by regular intervals other than a factor of 2
*				  between adjacent zoom levels per OGC GeoPackage Clause 3.2.1.
*
*/

	@Test(groups = { "NSG" }, description = "NSG Req 22 (pixels sizes factor of 2)")
	public void NSG_PixelsSizeTests() throws SQLException 
	{
		String queryStr = "SELECT table_name FROM gpkg_contents WHERE data_type=\'tiles\';";
		
		double _delta = 0.0D;
		
		try (final Statement statement = this.databaseConnection.createStatement();
             final ResultSet resultSet = statement.executeQuery(queryStr))
		{				
			while (resultSet.next()) 
			{
				String _tabNam = resultSet.getString("table_name").trim();
				String subQueryStr = "SELECT pixel_x_size, pixel_y_size FROM gpkg_tile_matrix "
					  	           + "WHERE table_name=\'" + _tabNam + "\' ORDER BY zoom_level;";
				
				try (final Statement subStatement = this.databaseConnection.createStatement();
		             final ResultSet subResultSet = subStatement.executeQuery(subQueryStr))
				{				
					double _pixelSzX = -1.0D;
					double _pixelSzY = -1.0D;

					while (subResultSet.next()) 
					{
						double _lastPixelSzX = _pixelSzX;
						double _lastPixelSzY = _pixelSzY;
						_pixelSzX = subResultSet.getDouble("pixel_x_size");
						_pixelSzY = subResultSet.getDouble("pixel_y_size");
						
						if (_lastPixelSzX < 0.0D) {
							_lastPixelSzX = _pixelSzX * 2.0D;
							_lastPixelSzY = _pixelSzY * 2.0D;
						}

						_delta = Math.abs((_pixelSzX * 2.0D ) - _lastPixelSzX);
						Assert.assertTrue(( _delta < this.tolerance ),
											MessageFormat.format(
													"The gpkg_tile_matrix contains an invalid pixel_x_size: {0} for {1}",
													String.format("%.10f",_pixelSzX), 
													_tabNam )
										);
						_delta = Math.abs((_pixelSzY * 2.0D ) - _lastPixelSzY);
						Assert.assertTrue(( _delta < this.tolerance ),
											MessageFormat.format(
													"The gpkg_tile_matrix contains an invalid pixel_y_size: {0} for {1}",
													String.format("%.10f",_pixelSzY), 
													_tabNam )
										);
					}
					subResultSet.close();
					subStatement.close();		
				}
			}
			resultSet.close();
			statement.close();
		}	
	}

	// ----------------------------------------------------	
	/*
	* --- NSG Req 23: The (min_x, min_y, max_x, max_y) values in the gpkg_tile_matrix_set
	* 				  table SHALL be the maximum bounds of the CRS specified for the tile pyramid data table and
	* 				  SHALL be used to determine the geographic position of each tile in the tile pyramid data
	* 				  table.
	*
	*/
	
	@Test(groups = { "NSG" }, description = "NSG Req 23 (bounding box in gpkg_tile_matrix_set)")
	public void NSG_BoundingBoxTests() throws SQLException
	{
		String queryStr = "SELECT table_name, srs_id, min_x, min_y, max_x, max_y FROM gpkg_tile_matrix_set;";
		
		try (final Statement statement = this.databaseConnection.createStatement();
             final ResultSet resultSet = statement.executeQuery(queryStr))
		{				
			while (resultSet.next()) 
			{
				String srsID   = resultSet.getString("srs_id").trim();
				String _tabNam = resultSet.getString("table_name").trim();
				double[] mbr = null;
				
				if (srsID.equals("3395"))
				{
					mbr = new double[] { -20037508.342789244D, -20037508.342789244D, 20037508.342789244D, 20037508.342789244D };
				}
				else if (srsID.equals("5041"))
				{
					mbr = new double[] { -14440759.350252D, -14440759.350252D, 18440759.350252D, 18440759.350252D };
				}
				else if (srsID.equals("4326")) 
				{
					mbr = new double[] { -180.0D, -90.0D, 180.0D, 90.0D };
				}

				Assert.assertTrue(( mbr != null ),
									MessageFormat.format(
											"The gpkg_tile_matrix_set contains an invalid CRS definition: {0} for table {1}",
											srsID,
											_tabNam )
								);
				
				double _val = resultSet.getDouble("min_x");
				Assert.assertTrue(( _val == mbr[0] ),
									MessageFormat.format(
											"The gpkg_tile_matrix_set contains an invalid min_x value: {0} for table {1} (should be {2})",
											Double.valueOf(_val),
											_tabNam,
											Double.valueOf(mbr[0]) )
								);
				
				_val = resultSet.getDouble("min_y");
				Assert.assertTrue((_val == mbr[1] ),
									MessageFormat.format(
											"The gpkg_tile_matrix_set contains an invalid min_y value: {0} for table {1} (should be {2})",
											Double.valueOf(_val),
											_tabNam, 
											Double.valueOf(mbr[1]) )
								);
				
				_val = resultSet.getDouble("max_x");
				Assert.assertTrue((_val == mbr[2] ),
									MessageFormat.format(
											"The gpkg_tile_matrix_set contains an invalid max_x value: {0} for table {1} (should be {2})",
											Double.valueOf(_val),
											_tabNam,
											Double.valueOf(mbr[2]) )
								);
				
				_val = resultSet.getDouble("max_y");
				Assert.assertTrue((_val == mbr[3] ),
									MessageFormat.format(
											"The gpkg_tile_matrix_set contains an invalid max_y value: {0} for table {1} (should be {2})",
											Double.valueOf(_val),
											_tabNam,
											Double.valueOf(mbr[3]) )
								);
			}
			resultSet.close();
			statement.close();
		}
	}		
	
// ----------------------------------------------------	

// ----------------------------------------------------	
				
}