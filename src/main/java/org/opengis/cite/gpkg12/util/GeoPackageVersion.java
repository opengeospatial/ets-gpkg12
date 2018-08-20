package org.opengis.cite.gpkg12.util;

/**
 * Discriminates the supported versions.
 *
 * @author <a href="mailto:goltz@lat-lon.de">Lyn Goltz </a>
 */
public enum GeoPackageVersion {

    V102( 102 ), V110( 110 ), V120( 120 );

    private int version;

    GeoPackageVersion( int version ) {
        this.version = version;
    }

}