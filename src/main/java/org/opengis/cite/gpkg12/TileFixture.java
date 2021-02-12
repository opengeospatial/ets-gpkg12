package org.opengis.cite.gpkg12;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.Map;
import java.util.Spliterator;
import java.util.Spliterators;
import java.util.stream.Collectors;
import java.util.stream.StreamSupport;

import javax.imageio.ImageIO;
import javax.imageio.ImageReader;
import javax.imageio.stream.ImageInputStream;
import javax.imageio.stream.MemoryCacheImageInputStream;

import org.opengis.cite.gpkg12.util.DatabaseUtility;
import org.testng.Assert;
import org.testng.annotations.BeforeClass;

public abstract class TileFixture extends CommonFixture {

	protected static boolean isEqual(final double first, final double second) {
		return Math.abs(first - second) < EPSILON;
	}

	/**
	 * Sets up variables used across methods
	 *
	 * @throws SQLException if there is a database error
	 */
	@BeforeClass
	public void setUp() throws SQLException {
		final Collection<String> extensionTableNames = new ArrayList<String>();
	
		// We may have tiles tables that are handled by an extension
		if (DatabaseUtility.doesTableOrViewExist(this.databaseConnection, "gpkg_extensions")){
			try (
					final Statement statement2 = this.databaseConnection.createStatement();
	
					final ResultSet resultSet2 = statement2.executeQuery("SELECT table_name FROM gpkg_extensions WHERE column_name = 'tile_data';");
					) {
				while(resultSet2.next()) {
					final String tableName = resultSet2.getString(1);
					extensionTableNames.add(tableName);
				}
			}
		}
	
		try (
				final Statement statement = this.databaseConnection.createStatement();
	
				final ResultSet resultSet = statement.executeQuery(String.format("SELECT table_name FROM gpkg_contents WHERE data_type = '%s';", dataType));
				) {
			while(resultSet.next())
			{
				final String tableName = resultSet.getString(1);
				this.tileTableNames.add(tableName);
			}
			this.tileTableNames.removeAll(extensionTableNames);
			Assert.assertTrue(!this.tileTableNames.isEmpty(), ErrorMessage.format(ErrorMessageKeys.CONFORMANCE_CLASS_DISABLED, getTestName()));    		
		}
	}

	protected static boolean canReadImage(final Iterable<ImageReader> imageReaders, final ImageInputStream image) throws IOException {
		for(final ImageReader imageReader : imageReaders)
		{
			try
			{
				image.mark();
				if(imageReader.getOriginatingProvider().canDecodeInput(image))
				{
					return true;
				}
			}
			finally
			{
				image.reset();
			}
		}
	
		return false;
	}

	protected boolean isAcceptedImageFormat(final byte[] image) throws IOException {
		if(image == null)
		{
			return false;
		}
	
		try(final ByteArrayInputStream        byteArray  = new ByteArrayInputStream(image);
				final MemoryCacheImageInputStream cacheImage = new MemoryCacheImageInputStream(byteArray))
		{
			return canReadImage(pngImageReaders, cacheImage) || canReadImage(jpegImageReaders, cacheImage);
		}
	}

	private String dataType = "tiles";

	protected void setDataType(String dataType) {
		this.dataType = dataType;
	}

	protected final Collection<String> tileTableNames = new ArrayList<String>();
	private static final double EPSILON = 0.0001;
	protected static final Collection<ImageReader> jpegImageReaders;
	protected static final Collection<ImageReader> pngImageReaders;
	protected static final Map<String, ColumnDefinition> TileTableExpectedColumns;

	public TileFixture() {
		super();
	}

	static
	{
		jpegImageReaders = StreamSupport.stream(Spliterators.spliteratorUnknownSize(ImageIO.getImageReadersByMIMEType("image/jpeg"),
				Spliterator.ORDERED),
				false)
				.collect(Collectors.toCollection(ArrayList::new));

		pngImageReaders  = StreamSupport.stream(Spliterators.spliteratorUnknownSize(ImageIO.getImageReadersByMIMEType("image/png"),
				Spliterator.ORDERED),
				false)
				.collect(Collectors.toCollection(ArrayList::new));

		TileTableExpectedColumns = new HashMap<>();

		TileTableExpectedColumns.put("id",           new ColumnDefinition("INTEGER", false, true,  true,  null));
		TileTableExpectedColumns.put("zoom_level",   new ColumnDefinition("INTEGER", true,  false, false, null));
		TileTableExpectedColumns.put("tile_column",  new ColumnDefinition("INTEGER", true,  false, false, null));
		TileTableExpectedColumns.put("tile_row",     new ColumnDefinition("INTEGER", true,  false, false, null));
		TileTableExpectedColumns.put("tile_data",    new ColumnDefinition("BLOB",    true,  false, false, null));
	}

}