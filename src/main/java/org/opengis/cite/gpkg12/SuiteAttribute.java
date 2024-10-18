package org.opengis.cite.gpkg12;

import java.io.File;

import org.opengis.cite.gpkg12.util.GeoPackageVersion;
import org.w3c.dom.Document;

import jakarta.ws.rs.client.Client;

/**
 * An enumerated type defining ISuite attributes that may be set to constitute a shared
 * test fixture.
 */
@SuppressWarnings("rawtypes")
public enum SuiteAttribute {

	/**
	 * A client component for interacting with HTTP endpoints.
	 */
	CLIENT("httpClient", Client.class),
	/**
	 * A DOM Document that represents the test subject or metadata about it.
	 */
	TEST_SUBJECT("testSubject", Document.class),
	/**
	 * A File containing the test subject or a description of it.
	 */
	TEST_SUBJ_FILE("testSubjectFile", File.class),
	/**
	 * A File containing the test subject or a description of it.
	 */
	GPKG_VERSION("geopackageVersion", GeoPackageVersion.class);

	private final Class attrType;

	private final String attrName;

	SuiteAttribute(String attrName, Class attrType) {
		this.attrName = attrName;
		this.attrType = attrType;
	}

	public Class getType() {
		return attrType;
	}

	public String getName() {
		return attrName;
	}

	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder(attrName);
		sb.append('(').append(attrType.getName()).append(')');
		return sb.toString();
	}

}
