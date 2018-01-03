package org.opengis.cite.gpkg12.nsg.core;

import org.opengis.cite.gpkg12.ErrorMessage;
import org.opengis.cite.gpkg12.ErrorMessageKeys;
import org.opengis.cite.gpkg12.GPKG12;
import org.opengis.cite.gpkg12.core.SQLiteContainerTests;
import org.testng.Assert;
import org.testng.annotations.Test;


public class NSG_SQLiteContainerTests extends SQLiteContainerTests 
{
	// ----------------------------------------------------	
	/*
	 * --- NSG Req 1: GeoPackages that contains NSG data SHALL use the “gpkg” file
	 *                extension. They SHALL NOT use the “gpkx” file extension to indicate that they are
	 *                Extended GeoPackages.
	 */
	
	@Test(groups = { "NSG" }, description = "NSG Req 1 (Geopackage name extension)")
	public void NSG_filenameExtension() 
	{
		String fileName = this.gpkgFile.getName();
		String suffix = fileName.substring(fileName.lastIndexOf('.'));
		Assert.assertEquals( suffix, GPKG12.GPKG_FILENAME_SUFFIX, ErrorMessage.format(ErrorMessageKeys.INVALID_SUFFIX, suffix ));
		Assert.assertNotEquals(suffix, ".gpkx", ErrorMessage.format(ErrorMessageKeys.INVALID_SUFFIX, suffix ));
	}
	
	// ----------------------------------------------------
	
	// ----------------------------------------------------
	
}
