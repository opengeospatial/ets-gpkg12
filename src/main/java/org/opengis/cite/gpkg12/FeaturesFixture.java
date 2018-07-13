package org.opengis.cite.gpkg12;

import java.util.Arrays;
import java.util.Collection;

public class FeaturesFixture extends CommonFixture {

	protected static final String geomGEOMETRY = "GEOMETRY";
	protected static final String geomPOINT = "POINT";
	protected static final String geomLINESTRING = "LINESTRING";
	protected static final String geomPOLYGON = "POLYGON";
	protected static final String geomMULTIPOINT = "MULTIPOINT";
	protected static final String geomMULTILINESTRING = "MULTILINESTRING";
	protected static final String geomMULTIPOLYGON = "MULTIPOLYGON";
	protected static final String geomGEOMETRYCOLLECTION = "GEOMETRYCOLLECTION";
	protected static final Collection<String> ALLOWED_GEOMETRY_TYPES = Arrays.asList(geomGEOMETRY,geomPOINT,geomLINESTRING,geomPOLYGON,geomMULTIPOINT,geomMULTILINESTRING,geomMULTIPOLYGON,geomGEOMETRYCOLLECTION);

	protected static Collection<String> getAllowedGeometryTypes() {
		return ALLOWED_GEOMETRY_TYPES;
	}

	public FeaturesFixture() {
		super();
	}

}