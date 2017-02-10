/* The MIT License (MIT)
 *
 * Copyright (c) 2015 Reinventing Geospatial, Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
package org.opengis.cite.gpkg12;

/**
 * @author Luke Lambert
 *
 */
public class ForeignKeyDefinition
{
    /**
     * @param referenceTableName the table name with the foreign key constraint
     * @param fromColumnName the name of the column that the link between two tables is from
     * @param toColumnName the name of the column that the link between two tables is to
     */
    public ForeignKeyDefinition(final String referenceTableName, final String fromColumnName, final String toColumnName)
    {
        if(referenceTableName == null || referenceTableName.isEmpty())
        {
            throw new IllegalArgumentException("Reference table name may not be null or empty");
        }

        if(fromColumnName == null || fromColumnName.isEmpty())
        {
            throw new IllegalArgumentException("From column name table name may not be null or empty");
        }

        if(toColumnName == null || toColumnName.isEmpty())
        {
            throw new IllegalArgumentException("To column name may not be null or empty");
        }

        this.referenceTableName = referenceTableName;
        this.fromColumnName     = fromColumnName;
        this.toColumnName       = toColumnName;
    }

    @Override
    public boolean equals(final Object object)
    {
        if(!(object instanceof ForeignKeyDefinition))
        {
            return false;
        }

        if(object == this)
        {
            return true;
        }

        final ForeignKeyDefinition other = (ForeignKeyDefinition)object;

        return this.referenceTableName.equals(other.referenceTableName) &&
               this.    fromColumnName.equals(other.    fromColumnName) &&
               this.      toColumnName.equals(other.      toColumnName);

    }

    @Override
    public int hashCode()
    {
        return this.referenceTableName.hashCode() ^
               this.    fromColumnName.hashCode() ^
               this.      toColumnName.hashCode();
    }

    /**
     * @return the referenceTableName
     */
    public String getReferenceTableName()
    {
        return this.referenceTableName;
    }

    /**
     * @return the fromColumnName
     */
    public String getFromColumnName()
    {
        return this.fromColumnName;
    }

    /**
     * @return the toColumnName
     */
    public String getToColumnName()
    {
        return this.toColumnName;
    }

    private final String referenceTableName;
    private final String     fromColumnName;
    private final String       toColumnName;
}
