<?xml version="1.0" encoding="utf-8"?>
<!-- 
Text Encoding Initiative Consortium XSLT stylesheet family
$Date: 2005/01/24 00:07:55 $, $Revision: 1.6 $, $Author: rahtz $

XSL stylesheet to process TEI documents using ODD markup

 
Copyright 1999-2005 Sebastian Rahtz / Text Encoding Initiative Consortium
    This is an XSLT stylesheet for transforming TEI (version P4) XML documents

    Version 4.3.5. Date Thu Mar 10 16:22:09 GMT 2005

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    The author may be contacted via the e-mail address

    sebastian.rahtz@computing-services.oxford.ac.uk--> 
<xsl:stylesheet 
 xmlns:rng="http://relaxng.org/ns/structure/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  extension-element-prefixes="exsl"
  exclude-result-prefixes="tei exsl" 
  version="1.0">
  <xsl:output method="xml" indent="yes"/>
<xsl:key name="TAGMODS" match="Tag|AttClass" use="Tagset"/>
<xsl:key name="MODS" match="moduleRef" use="@key"/>
<xsl:output method="xml" indent="yes"/>
<xsl:param name="verbose"></xsl:param>
<xsl:param name="lang">es</xsl:param>
<xsl:key name="ELEMENTS" match="element" use="@ident"/>
<xsl:key name="ATTRIBUTES" match="attribute" use="@ident"/>
<xsl:param name="TEISERVER">http://localhost/TEI/Roma/xquery/</xsl:param>
<xsl:template match="*|rng:*">
  <xsl:copy>
    <xsl:apply-templates select="@*|*|text()|comment()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="@*|comment()|text()">
  <xsl:copy/>
</xsl:template>

<xsl:template match="elementSpec[@mode='change']">
  <xsl:copy>
    <xsl:apply-templates select="@*|*|text()|comment()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="schemaSpec">
  <xsl:copy>
    <xsl:apply-templates select="@*|*|text()|comment()"/>
    <xsl:for-each select="moduleRef">
	<xsl:call-template name="findTranslateNames">
	  <xsl:with-param name="modname">
	    <xsl:value-of select="@key"/>
	  </xsl:with-param>
	</xsl:call-template>
    </xsl:for-each>
  </xsl:copy>
</xsl:template>

<xsl:template name="findTranslateNames">
  <xsl:param name="modname"/>
  <xsl:variable name="HERE" select="."/>
  <xsl:variable name="loc">
    <xsl:value-of select="$TEISERVER"/>
    <xsl:text>objectsbymod.xq?module=</xsl:text>
    <xsl:value-of select="$modname"/>
  </xsl:variable>
  <xsl:variable name="i18n">
    <xsl:value-of select="$TEISERVER"/>
    <xsl:text>i18n.xq</xsl:text>
  </xsl:variable>
  <xsl:for-each select="document($loc)/List/Object">
    <xsl:variable name="thisthing" select="Name"/>
      <xsl:variable name="ename">	
	<xsl:choose>
	  <xsl:when test="$HERE/*[@ident=$thisthing]">
	    <xsl:if
		test="$HERE/elementSpec[@ident=$thisthing]/attList">
	    </xsl:if>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:for-each  select="document($i18n)">
	      <xsl:for-each select="key('ELEMENTS',$thisthing)">
		<xsl:if test="equiv[xml:lang=$lang][not(@value='')]">
		  <xsl:if test="$verbose='true'">
		    <xsl:message> ... <xsl:value-of select="equiv[xml:lang=$lang]/@value"/></xsl:message>
		  </xsl:if>
		  <altIdent type="lang" xmlns="http://www.tei-c.org/ns/1.0">
		    <xsl:value-of select="equiv[@xml:lang=$lang]/@value"/>
		  </altIdent>
		</xsl:if>
	      </xsl:for-each>
	    </xsl:for-each>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:variable>
      <xsl:variable name="aname">
	<xsl:choose>
	  <xsl:when test="$HERE/*[@ident=$thisthing]">
	    <xsl:if
		test="$HERE/elementSpec[@ident=$thisthing]/attList">
	    </xsl:if>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:if test="Attributes/attribute">
	      <attList xmlns="http://www.tei-c.org/ns/1.0">
		<xsl:for-each select="Attributes/attribute">
		  <xsl:variable name="thisatt" select="."/>
		  <xsl:for-each  select="document($i18n)">
		    <xsl:for-each select="key('ATTRIBUTES',$thisatt)">
		      <xsl:if test="equiv[@xml:lang=$lang][not(@value='')]">
			<attDef mode="change" xmlns="http://www.tei-c.org/ns/1.0" ident="{$thisatt}"> 
			  <altIdent type="lang" xmlns="http://www.tei-c.org/ns/1.0">
			    <xsl:value-of select="equiv[@xml:lang=$lang]/@value"/>
			  </altIdent>
			</attDef>
		      </xsl:if>
		    </xsl:for-each>
		  </xsl:for-each>
		</xsl:for-each>
	      </attList>
	    </xsl:if>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:variable>
      <xsl:if test="string-length($aname)&gt;0 or
		    string-length($ename)&gt;0">
	<xsl:if test="$verbose='true'">
	  <xsl:message><xsl:value-of select="$modname"/>: <xsl:value-of select="$thisthing"/></xsl:message>
	</xsl:if>
	<xsl:choose>
	  <xsl:when test="starts-with($thisthing,'tei.')">
	    <classSpec ident="{$thisthing}" 
		       module="{$modname}"
		       mode="change" 
		       xmlns="http://www.tei-c.org/ns/1.0">
	      <xsl:copy-of select="$aname"/>
	    </classSpec>
	  </xsl:when>
	  <xsl:otherwise>
	    <elementSpec ident="{$thisthing}" 
			 module="{$modname}"
			 mode="change" xmlns="http://www.tei-c.org/ns/1.0">
	      <xsl:copy-of select="$ename"/>
	      <xsl:copy-of select="$aname"/>
	    </elementSpec>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:if>
  </xsl:for-each>
</xsl:template>


</xsl:stylesheet>
