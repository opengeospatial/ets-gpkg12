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

import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;

/**
 * @author Luke Lambert
 *
 */
public class UniqueDefinition
{
    /**
     * @param columnNames
     *            the names of the columns that have the SQLite property of Unique
     */
    public UniqueDefinition(final String... columnNames)
    {
        this(Arrays.asList(columnNames));
    }

    /**
     * @param columnNames
     *            the names of the columns that have the SQLite property of
     *            Unique
     */
    public UniqueDefinition(final Collection<String> columnNames)
    {
        this.columnNames = new HashSet<>(columnNames);
    }

    /**
     * @return the columnNames the names of the columns that have the SQLite
     *         property of Unique
     */
    public Set<String> getColumnNames()
    {
        return Collections.unmodifiableSet(this.columnNames);
    }

    /**
     * @param columnName the name of the column
     * @return true if the column name given is in the set of this.columnNames; otherwise returns false.
     */
    public boolean equals(final String columnName)
    {
        return this.columnNames.size() == 1 &&
               this.columnNames.contains(columnName);
    }

    @Override
    public boolean equals(final Object object)
    {
        if(!(object instanceof UniqueDefinition))
        {
            return false;
        }
        if(this == object)
        {
            return true;
        }

        final UniqueDefinition other = (UniqueDefinition)object;

        return this.columnNames.containsAll(other.columnNames) &&
               other.columnNames.containsAll( this.columnNames);
    }

    @Override
    public int hashCode()
    {
        return this.columnNames.hashCode();
    }

    private final Set<String> columnNames;
}
