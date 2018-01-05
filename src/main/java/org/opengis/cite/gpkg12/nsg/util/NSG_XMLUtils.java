
package org.opengis.cite.gpkg12.nsg.util;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.StringReader;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import org.opengis.cite.gpkg12.util.XMLUtils;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.w3c.dom.Node;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

public class NSG_XMLUtils extends XMLUtils
{
	public static String getXMLElementTextValue(Element ele, String tagName)
	{
		String textVal = null;
		NodeList nl = ele.getElementsByTagName(tagName);
		if (nl != null && nl.getLength() > 0)
		{
			Element el = (Element) nl.item(0);
			textVal = el.getFirstChild().getNodeValue();
		}

		return textVal;
	}

	// ----------------------------------------------------
	
	public static Element getElement(NodeList nodes, String tagName, String value)
	{
		Element ele = null;
		for (int ni=0; ni<nodes.getLength(); ni++)
		{
			Element e = (Element)nodes.item(ni);  
			if (getXMLElementTextValue(e,tagName).equalsIgnoreCase(value))
			{
				ele = e;
				break;
			}
		}
		return ele;
	}
	
	// ----------------------------------------------------

	public static NodeList openXMLDocString(String _xmlStr, String rootName)
	{
		DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();

		try 
		{
			DocumentBuilder docBld = dbf.newDocumentBuilder();
			Document doc = docBld.parse(new InputSource(new StringReader(_xmlStr)));
			if (doc != null)
			{
				Element docElems = doc.getDocumentElement();
				if (docElems != null)
				{
					return docElems.getElementsByTagName(rootName);
				}
			}
		}
		catch (ParserConfigurationException pcEx) 
		{
			pcEx.printStackTrace();
		} 
		catch (SAXException saxEx)
		{
			saxEx.printStackTrace();
		} 
		catch (IOException ioEx)
		{
			ioEx.printStackTrace();
		}

		return null;
	}

	// ----------------------------------------------------
	
	public static NodeList openXMLDocument(String xmlName, String rootName)
	{
		DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();

		try
		{
			DocumentBuilder ioe = dbf.newDocumentBuilder();
			Document dom = ioe.parse(xmlName);
			if (dom != null) {
				Element docElems = dom.getDocumentElement();
				if (docElems != null) {
					return docElems.getElementsByTagName(rootName);
				}
			}
		}
		catch (ParserConfigurationException pcEx)
		{
			pcEx.printStackTrace();
		}
		catch (SAXException saxEx)
		{
			saxEx.printStackTrace();
		}
		catch (IOException ioEx)
		{
			ioEx.printStackTrace();
		}

		return null;
	}
	
	// ----------------------------------------------------
	
	public static NodeList openXMLDocument(InputStream xml_IS, String rootName)
	{
		DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();

		try
		{
			DocumentBuilder ioe = dbf.newDocumentBuilder();
			Document dom = ioe.parse(xml_IS);
			if (dom != null) {
				Element docElems = dom.getDocumentElement();
				if (docElems != null) {
					return docElems.getElementsByTagName(rootName);
				}
			}
		}
		catch (ParserConfigurationException pcEx)
		{
			pcEx.printStackTrace();
		}
		catch (SAXException saxEx)
		{
			saxEx.printStackTrace();
		}
		catch (IOException ioEx)
		{
			ioEx.printStackTrace();
		}

		return null;
	}
	
	// ----------------------------------------------------
}