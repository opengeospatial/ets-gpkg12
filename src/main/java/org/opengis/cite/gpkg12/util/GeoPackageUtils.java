package org.opengis.cite.gpkg12.util;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.Arrays;

import org.opengis.cite.gpkg12.GPKG12;

/**
 * @author <a href="mailto:goltz@lat-lon.de">Lyn Goltz </a>
 */
public class GeoPackageUtils {

	private GeoPackageUtils() {
	}

	/**
	 * @param gpkgFile never <code>null</code>
	 * @return the bytes that make up the application ID
	 * @throws IOException tf the file could not be read
	 */
	public static final byte[] getAppId(File gpkgFile) throws IOException {
		return Arrays.copyOfRange(getHeaderBytes(gpkgFile), GPKG12.APP_ID_OFFSET, GPKG12.APP_ID_OFFSET + 4);
	}

	/**
	 * @param gpkgFile never <code>null</code>
	 * @return the bytes that make up the header
	 * @throws IOException tf the file could not be read
	 */
	private static final byte[] getHeaderBytes(File gpkgFile) throws IOException {
		final byte[] headerBytes = new byte[GPKG12.DB_HEADER_LENGTH];
		try (FileInputStream fileInputStream = new FileInputStream(gpkgFile)) {
			fileInputStream.read(headerBytes);
		}
		return headerBytes;
	}

}
