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
@SuppressWarnings("NegativelyNamedBooleanVariable")
public class ColumnDefinition
{
    /**
     * @param sqlType
     *             String representing the SQL type of the column, e.g.: TEXT, INTEGER, and so on
     * @param notNull
     *             Indicates that this column may not contain null values
     * @param primaryKey
     *             Indicates that this column is the table's primary key (implicitly unique)
     * @param unique
     *             Indicates that values for this column are unique. If primaryKey is true, this value is ignored
     * @param defaultValue
     *             String representation for the default value of this column
     */
    @SuppressWarnings("BooleanParameter")
    public ColumnDefinition(final String  sqlType,
                            final boolean notNull,
                            final boolean primaryKey,
                            final boolean unique,
                            final String  defaultValue)
    {
        if(sqlType == null)
        {
            throw new IllegalArgumentException("SQL type may not be null");
        }

        this.sqlType      = sqlType;
        this.notNull      = notNull;
        this.defaultValue = defaultValue;
        this.primaryKey   = primaryKey;
        this.unique       = primaryKey || unique;
    }

    @Override
    public boolean equals(final Object object)
    {
        if(!(object instanceof ColumnDefinition))
        {
            return false;
        }

        if(this == object)
        {
            return true;
        }

        final ColumnDefinition other = (ColumnDefinition)object;

        // This was added on behalf of Richard Martell, based on the following
        // justification:
        //
        // "According to the SQL standard, PRIMARY KEY should always imply NOT
        // NULL. Unfortunately, due to a bug in some early versions, this is
        // not the case in SQLite. Unless the column is an INTEGER PRIMARY KEY
        // or the table is a WITHOUT ROWID table or the column is declared NOT
        // NULL, SQLite allows NULL values in a PRIMARY KEY column. SQLite
        // could be fixed to conform to the standard, but doing so might break
        // legacy applications. Hence, it has been decided to merely document
        // the fact that SQLite allowing NULLs in most PRIMARY KEY columns."
        //
        // ref: https://www.sqlite.org/lang_createtable.html#constraints
        //
        // This addition allows the column definition checks to be more
        // permissive (i.e. allow implicit NOT NULL) for PK columns of type
        // INTEGER.
        final boolean implicitNotNull = this.primaryKey &&
                                        this.sqlType.toUpperCase().equals("INTEGER");

        return this.sqlType.equals(other.sqlType)                      &&
               ((this.notNull    == other.notNull) || implicitNotNull) &&
               this.primaryKey   == other.primaryKey  &&
               this.unique       == other.unique     /*&&
               (this.defaultValue == null ? other.defaultValue == null : this.defaultValue.equals(other.defaultValue))*/; // Skip the test for equality in favor of a functional equivalence test with a query
    }

    @Override
    public int hashCode()
    {
        return this.sqlType.hashCode()   ^
               (this.notNull    ? 1 : 0) ^
               (this.primaryKey ? 1 : 0) ^
               (this.unique     ? 1 : 0) ^
               (this.defaultValue == null ? 0 : this.defaultValue.hashCode());
    }

    @Override
    public String toString()
    {
        return String.format("Type: %s, not null: %s, default value: %s, primary key: %s, unique: %s",
                             this.sqlType,
                             this.notNull,
                             this.defaultValue,
                             this.primaryKey,
                             this.unique);
    }

    public String getDefaultValue()
    {
        return this.defaultValue;
    }

    private final String  sqlType;
    private final boolean notNull;
    private final boolean primaryKey;
    private final boolean unique;
    private final String  defaultValue;
}
