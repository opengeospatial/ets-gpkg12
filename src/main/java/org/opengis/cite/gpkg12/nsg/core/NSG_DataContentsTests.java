
package org.opengis.cite.gpkg12.nsg.core;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.MessageFormat;
import java.util.Collection;
import java.util.LinkedList;
//import java.util.function.Function;
import java.util.stream.Collectors;
import org.opengis.cite.gpkg12.ErrorMessage;
import org.opengis.cite.gpkg12.ErrorMessageKeys;
import org.opengis.cite.gpkg12.core.DataContentsTests;
import org.testng.Assert;
import org.testng.annotations.Test;

public class NSG_DataContentsTests extends DataContentsTests
{
	final private double tolerance = 1.0e-10;
	
	// ----------------------------------------------------	

	private double checkFeatureBounds(String _tableName, String _boundsColumn) throws SQLException
	{
		// --- convenience routine to consistently convert specific bounds column from ST_Geometry into double
		
		String queryStr = "SELECT column_name FROM gpkg_geometry_columns WHERE table_name=\'" + _tableName + "\';";
		String _colName = null;

		try (final Statement statement = this.databaseConnection.createStatement();
	         final ResultSet resultSet = statement.executeQuery(queryStr))
		{
			Assert.assertTrue(resultSet.next(), 
					      		"Invalid no result from table: <gpkg_geometry_columns>");
		
			_colName = resultSet.getString("column_name");
		
			resultSet.close();
			statement.close();
		}	
			
	    String _func1 = _boundsColumn;
		if (_boundsColumn.equals("min_x"))
		{
			_func1 = "ST_MinX";
		}
		else if (_boundsColumn.equals("min_y")) 
		{
			_func1 = "ST_MinY";
		} 
		else if (_boundsColumn.equals("min_x")) 
		{
			_func1 = "ST_MinX";
		}
		else if (_boundsColumn.equals("min_y"))
		{
			_func1 = "ST_MinY";
		}

		double _result = Double.NaN;
		
		queryStr = "SELECT " + _func1 + "(" + _colName + ") AS theResult FROM " + _tableName + ";";
		
		try (final Statement statement = this.databaseConnection.createStatement();
		     final ResultSet resultSet = statement.executeQuery(queryStr))
		{
			Assert.assertTrue(resultSet.next(),
								"Invalid no result from " + _func1 + "(" + _colName + ") in table:  " + _tableName);

			_result = resultSet.getDouble("theResult");
					
			resultSet.close();
			statement.close();
		}
		
		return _result;
	}

	// ----------------------------------------------------	

	private double checkTileBounds(String _tableName, String _boundsColumn) throws SQLException
	{
		// --- convenience routine to consistently return specific bounds column as double
		
		String queryStr = "SELECT " + _boundsColumn + " FROM gpkg_tile_matrix_set WHERE table_name = \'" + _tableName + "\';";
		
		double _result = Double.NaN;
		
		try (final Statement statement = this.databaseConnection.createStatement();
		     final ResultSet resultSet = statement.executeQuery(queryStr))
		{
			Assert.assertTrue(resultSet.next(),
				ErrorMessage.format(ErrorMessageKeys.BAD_TILE_MATRIX_SET_TABLE_DEFINITION));
			
			_result = resultSet.getDouble(_boundsColumn);

			resultSet.close();
			statement.close();
		}

		return _result;
	}

	// ----------------------------------------------------	
	/*
	 * --- NSG Req 19: Data validity SHALL be assessed against data value constraints specified
	 * 				   in Table 26 below using a test suite. Data validity MAY be enforced by SQL triggers.
	 * 
	 *     --- 19-B:  Addresses Table 26 Rows 3-7 (regarding table "gpkg_contents")
	 */

	@Test(groups = { "NSG" }, description = "NSG Req 19-B (Data Validity: gpkg_contents)")
	public void NSG_DataValidity() throws SQLException
	{
		String queryStr = "SELECT srs_id,table_name,data_type,min_x,min_y,max_x,max_y FROM gpkg_contents;";
		
		try (final Statement statement = this.databaseConnection.createStatement();
			 final ResultSet resultSet = statement.executeQuery(queryStr))
		{
			final Collection<String> invalidDataTypes = new LinkedList<>();
			final Collection<String> invalidMinX = new LinkedList<>();
			final Collection<String> invalidMinY = new LinkedList<>();
			final Collection<String> invalidMaxX = new LinkedList<>();
			final Collection<String> invalidMaxY = new LinkedList<>();

			while (resultSet.next())
			{
				String srsID = resultSet.getString("srs_id").trim();
				String srsTabNam = resultSet.getString("table_name").trim();
				String srsDataTyp = resultSet.getString("data_type").trim();
				
				boolean dtFeat = (srsDataTyp.equals("features"));
				boolean dtTile = (srsDataTyp.equals("tiles"));
				
				if (!dtFeat && !dtTile )
				{
					invalidDataTypes.add(srsTabNam + ":" + srsDataTyp);
				}

				double _val = 0.0D;
				double _bnd = 0.0D;
			
				// --- test for:  Table 26; Row 4
				
				String _testBoundsColumn = "min_x";
				if ( resultSet.getString(_testBoundsColumn) != null )
				{
					_val = resultSet.getDouble(_testBoundsColumn);					
					if ( dtFeat ) 
					{
						_bnd = this.checkFeatureBounds(srsTabNam, _testBoundsColumn);
						if (_val < _bnd )
						{
							invalidMinX.add(srsTabNam + ":" + _val + ", should be: " + _bnd );
						}
					} 
					else if ( dtTile )
					{
						_bnd =  this.checkTileBounds(srsTabNam, _testBoundsColumn);
						if (_val < _bnd )
						{
							invalidMinX.add(srsTabNam + ":" + _val + ", should be: " + _bnd );
						}
					}
				}

				// --- test for:  Table 26; Row 5
				
				_testBoundsColumn = "min_y";
				if (resultSet.getString(_testBoundsColumn) != null )
				{
					_val = resultSet.getDouble(_testBoundsColumn);
					if ( dtFeat )
					{
						_bnd = this.checkFeatureBounds(srsTabNam, _testBoundsColumn);
						if (_val < _bnd )
						{
							invalidMinY.add(srsTabNam + ":" + _val + ", should be: " + _bnd );
						}
					}
					else if ( dtTile )
					{
						_bnd = this.checkTileBounds(srsTabNam, _testBoundsColumn);			
						if (_val < _bnd )
						{
							invalidMinY.add(srsTabNam + ":" + _val + ", should be: " + _bnd );
						}
					}
				}

				// --- test for:  Table 26; Row 6
				
				_testBoundsColumn = "max_x";
				if ( resultSet.getString(_testBoundsColumn) != null )
				{
					_val = resultSet.getDouble(_testBoundsColumn);
					if ( dtFeat )
					{
						_bnd = this.checkFeatureBounds(srsTabNam, _testBoundsColumn) ;
						if (_val > _bnd )
						{
							invalidMaxX.add(srsTabNam + ":" + _val + ", should be: " + _bnd );
						}
					}
					else if ( dtTile )
					{
						_bnd = this.checkTileBounds(srsTabNam, _testBoundsColumn);
						if (_val > _bnd)
						{
							invalidMaxX.add(srsTabNam + ":" + _val + ", should be: " + _bnd );
						}
					}
				}

				// --- test for:  Table 26; Row 7
				
				_testBoundsColumn = "max_y";
				if ( resultSet.getString(_testBoundsColumn) != null )
				{
					_val = resultSet.getDouble(_testBoundsColumn);
					if ( dtFeat )
					{
						_bnd = this.checkFeatureBounds(srsTabNam, _testBoundsColumn);
						if (_val > _bnd)
						{
							invalidMaxY.add(srsTabNam + ":" + _val + ", should be: " + _bnd );
						} 
					}
					else if ( dtTile )
					{
						_bnd = this.checkTileBounds(srsTabNam, _testBoundsColumn);
						if (_val > _bnd )
						{
							invalidMaxY.add(srsTabNam + ":" + _val + ", should be: " + _bnd );
						}
					}
				}
			}
			resultSet.close();
			statement.close();
			
			Assert.assertTrue(invalidDataTypes.isEmpty(), 
								MessageFormat.format(
										"The gpkg_contents table contains invalid data type values for tables: {0}", 
										invalidDataTypes.stream().map(Object::toString).collect(Collectors.joining(", ")) )
							);
			Assert.assertTrue(invalidMinX.isEmpty(), 
								MessageFormat.format(
										"The gpkg_contents table contains invalid minimum X bounds values for tables: {0}",
										invalidMinX.stream().map(Object::toString).collect(Collectors.joining(", ")) )
							);
			Assert.assertTrue(invalidMinY.isEmpty(), 
								MessageFormat.format(
										"The gpkg_contents table contains invalid minimum Y bounds values for tables: {0}",
										invalidMinY.stream().map(Object::toString).collect(Collectors.joining(", ")) )
							);
			Assert.assertTrue(invalidMaxX.isEmpty(),
								MessageFormat.format(
										"The gpkg_contents table contains invalid maximum X bounds values for tables: {0}",
										invalidMaxX.stream().map(Object::toString).collect(Collectors.joining(", ")) )
								);
			Assert.assertTrue(invalidMaxY.isEmpty(), 
								MessageFormat.format(
										"The gpkg_contents table contains invalid maximum Y bounds values for tables: {0}",
										invalidMaxY.stream().map(Object::toString).collect(Collectors.joining(", ")) )
								);
		}
	}
			
	// ----------------------------------------------------	

	// ----------------------------------------------------	

}