package org.opengis.cite.gpkg12.nsg.metadata;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.net.URL;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import javax.xml.XMLConstants;
import javax.xml.transform.stream.StreamSource;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;
import javax.xml.validation.Validator;

import org.opengis.cite.gpkg12.CommonFixture;
import org.testng.annotations.Test;


public class MetadataTests extends CommonFixture
{

	/**
	 * Validate metadata against NMIS xsd
	 * https://nsgreg.nga.mil/doc/view?i=2491
	 */
	@Test(description = "Validate against NMIS schema")
	public void metadataSchemaValidation()
	{
		SchemaFactory schemaFactory = SchemaFactory.newInstance(XMLConstants.W3C_XML_SCHEMA_NS_URI);
		
        try 
        { 
        	URL resource = getClass().getClassLoader().getResource("org/opengis/cite/gpkg12/nsg/metadata/NMIS v2.X Schema/nas/nmis.xsd");        	
			Schema schema = schemaFactory.newSchema(resource);
	
			try (final Statement statement = this.databaseConnection.createStatement();
    				final ResultSet resultSet = statement.executeQuery("SELECT metadata FROM gpkg_metadata;"))
            {
				
				while(resultSet.next())
				{
					String xmlResult = resultSet.getString("metadata");					
	            	Validator validator = schema.newValidator();

	            	InputStream is = new ByteArrayInputStream(xmlResult.getBytes());
	                validator.validate(new StreamSource(is));
				}          	
            } catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
        } catch (Exception e)// (SAXException | IOException e)
        {
            e.printStackTrace();
        }
	}

}
