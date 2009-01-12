<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
 xmlns:xd="http://www.pnp-software.com/XSLTdoc"
 xmlns:tei="http://www.tei-c.org/ns/1.0" 
 xmlns:edate="http://exslt.org/dates-and-times" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
 extension-element-prefixes="edate" 
 exclude-result-prefixes="xd tei edate" 
 version="1.0">
  <xd:doc type="stylesheet">
    <xd:short>
    TEI stylesheet dealing  with elements from the linking module.
      </xd:short>
    <xd:detail>
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

   
   
      </xd:detail>
    <xd:author>Sebastian Rahtz sebastian.rahtz@oucs.ox.ac.uk</xd:author>
    <xd:cvsId>$Id: linking.xsl,v 1.1 2006/02/16 15:31:44 giacomi Exp $</xd:cvsId>
    <xd:copyright>2005, TEI Consortium</xd:copyright>
  </xd:doc>
  <xd:doc>
    <xd:short>Process elements  TEI.2</xd:short>
    <xd:detail>&#160;</xd:detail>
  </xd:doc>
  <xsl:template match="TEI.2" mode="xref"> 
  <xsl:apply-templates select="teiHeader/fileDesc/titleStmt/title"/>
</xsl:template>
  <xd:doc>
    <xd:short>Process elements  anchor|p</xd:short>
    <xd:detail>&#160;</xd:detail>
  </xd:doc>
  <xsl:template match="anchor|p" mode="xref">
  <xsl:text>here</xsl:text>
</xsl:template>
  <xd:doc>
    <xd:short>Process elements  bibl</xd:short>
    <xd:detail>&#160;</xd:detail>
  </xd:doc>
  <xsl:template match="bibl" mode="xref">
  <xsl:text>[</xsl:text><xsl:number/><xsl:text>]</xsl:text>
</xsl:template>
  <xd:doc>
    <xd:short>Process elements  biblStruct</xd:short>
    <xd:detail>&#160;</xd:detail>
  </xd:doc>
  <xsl:template match="biblStruct" mode="xref">
 <xsl:choose>
   <xsl:when test="descendant::author">
     <xsl:apply-templates select="descendant::author[position()=1]" mode="first"/>
   </xsl:when>
   <xsl:otherwise>
     <xsl:apply-templates select="descendant::editor[position()=1]" mode="first"/>
   </xsl:otherwise>
 </xsl:choose>
 <xsl:choose>
   <xsl:when test="descendant::title[@type='short']">
     <xsl:apply-templates select="descendant::title[@type='short']"/>
   </xsl:when>
   <xsl:otherwise>
     <xsl:apply-templates select="descendant::title[@type='main'][1]"/>
   </xsl:otherwise>
 </xsl:choose>
</xsl:template>
  <xd:doc>
    <xd:short>Process elements  div|div0|div1|div2|div3|div4|div5|div6</xd:short>
    <xd:param name="minimal">whether to make a link with just numbers
    or with text too</xd:param>
    <xd:detail>&#160;</xd:detail>
  </xd:doc>
  <xsl:template match="div|div0|div1|div2|div3|div4|div5|div6" mode="xref"> 
  <xsl:param name="minimal">false</xsl:param>
  <xsl:call-template name="header">
    <xsl:with-param name="minimal" select="$minimal"/>
  </xsl:call-template>
</xsl:template>
  <xd:doc>
    <xd:short>Process elements  note</xd:short>
    <xd:detail>&#160;</xd:detail>
  </xd:doc>
  <xsl:template match="note" mode="xref">
   <xsl:number level="any"/>
</xsl:template>
  <xd:doc>
    <xd:short>Process elements  ptr|xptr</xd:short>
    <xd:detail>&#160;</xd:detail>
  </xd:doc>
  <xsl:template match="ptr|xptr">
  <xsl:call-template name="makeTEILink">
    <xsl:with-param name="ptr">true</xsl:with-param>
  </xsl:call-template>
</xsl:template>
  <xd:doc>
    <xd:short>Process elements  ref|xref</xd:short>
    <xd:detail>&#160;</xd:detail>
  </xd:doc>
  <xsl:template match="ref|xref">
  <xsl:call-template name="makeTEILink">
    <xsl:with-param name="ptr">false</xsl:with-param>
  </xsl:call-template>
</xsl:template>

  <xd:doc>
    <xd:short>[common] Making a heading for something</xd:short>
    <xd:param name="minimal">false</xd:param>
    <xd:param name="toc">toc</xd:param>
    <xd:detail>&#160;</xd:detail>
  </xd:doc>
  <xsl:template name="header">
  <xsl:param name="minimal">false</xsl:param>
  <xsl:param name="toc"/>
  <xsl:variable name="depth">
    <xsl:apply-templates select="." mode="depth"/>
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="local-name(.) = 'TEI'"/>
    <xsl:when test="local-name(.) = 'TEI.2'"/>
    <xsl:when test="$depth &gt; $numberHeadingsDepth">
    </xsl:when>
    <xsl:when test="ancestor::back">
      <xsl:if test="not($numberBackHeadings='')">
	<xsl:call-template name="i18n">
	  <xsl:with-param
		 name="word">appendixWords</xsl:with-param></xsl:call-template>
	<xsl:text> </xsl:text>
	<xsl:call-template name="numberBackDiv"/>
	<xsl:if test="$minimal='false'">
	  <xsl:value-of select="$numberSpacer"/>
	</xsl:if>
      </xsl:if>
    </xsl:when>
    <xsl:when test="ancestor::front">
      <xsl:if test="not($numberFrontHeadings='')">
	<xsl:call-template name="numberFrontDiv"/>
	<xsl:if test="$minimal='false'">
	  <xsl:value-of select="$numberSpacer"/>
	</xsl:if>
      </xsl:if>
    </xsl:when>
    <xsl:when test="$numberHeadings ='true'">
      <xsl:choose>
	<xsl:when test="$prenumberedHeadings='true'">
	  <xsl:value-of select="@n"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:call-template name="numberBodyDiv"/>
	</xsl:otherwise>
      </xsl:choose>
      <xsl:if test="$minimal='false'">
	<xsl:value-of select="$headingNumberSuffix"/>
      </xsl:if>
    </xsl:when>
  </xsl:choose>
  <xsl:if test="$minimal='false'">
    <xsl:choose>
      <xsl:when test="local-name(.) = 'TEI' or local-name(.)='TEI.2'">
	<xsl:apply-templates select="teiHeader/fileDesc/titleStmt/title"/>
      </xsl:when>
      <xsl:when test="not(head) and @n">
	<xsl:value-of select="@n"/>
      </xsl:when>
      <xsl:when test="not($toc='')">
	  <xsl:call-template name="makeInternalLink">     
	    <xsl:with-param name="dest">
	      <xsl:value-of select="$toc"/>
	    </xsl:with-param>
	    <xsl:with-param name="class">
	      <xsl:value-of select="$class_toc"/>
	    </xsl:with-param>
	    <xsl:with-param name="body">
	      <xsl:choose>
		<xsl:when test="$autoHead='true'">
		  <xsl:call-template name="autoMakeHead"/>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:apply-templates mode="plain" select="head"/>
		</xsl:otherwise>
	      </xsl:choose>
	    </xsl:with-param>
	  </xsl:call-template>
      </xsl:when>
      <xsl:when test="$autoHead='true'">
	<xsl:call-template name="autoMakeHead"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates mode="plain" select="head"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
</xsl:template>


  <xd:doc>
    <xd:short>[common] Making a heading for something, and making sure
    it has contents</xd:short>
    <xd:param name="minimal">false</xd:param>
    <xd:detail>This is a wrapper around the "header" template which
    ensures that some text is returned; if all else fails, the element
    name of used.</xd:detail>
  </xd:doc>
  <xsl:template name="headerLink">
    <xsl:param name="minimal">false</xsl:param>
    <xsl:variable name="Text">
      <xsl:call-template name="header">
	<xsl:with-param name="minimal" select="$minimalCrossRef"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$Text=''">
	<xsl:text>&lt;</xsl:text>
	<xsl:value-of select="local-name(.)"/>
	<xsl:text>&gt;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
	<xsl:copy-of select="$Text"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xd:doc>
    <xd:short>[common] Make a hypertext link</xd:short>
    <xd:param name="ptr">ptr</xd:param>
    <xd:detail>
      <p> cross-referencing </p>
    </xd:detail>
  </xd:doc>
  <xsl:template name="makeTEILink">
<xsl:param name="ptr"/><!-- is this a ptr or a ref? -->
<xsl:choose>
  <!-- If there is a target attribute starting with #, it is always a local reference -->
  <xsl:when test="@target and starts-with(@target,'#')">
    <xsl:call-template name="makeInternalLink">
      <xsl:with-param name="target" select="substring-after(@target,'#')"/>
      <xsl:with-param name="ptr" select="$ptr"/>
      <xsl:with-param name="dest">
	<xsl:call-template name="generateEndLink">
	  <xsl:with-param name="where">
	    <xsl:value-of select="substring-after(@target,'#')"/>
	  </xsl:with-param>
	</xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:when>
<!-- if we are doing TEI P4, all targets are local -->
  <xsl:when test="@target and $teiP4Compat='true'">
    <xsl:call-template name="makeInternalLink">
      <xsl:with-param name="target" select="@target"/>
      <xsl:with-param name="ptr" select="$ptr"/>
      <xsl:with-param name="dest">
	<xsl:call-template name="generateEndLink">
	  <xsl:with-param name="where">
	    <xsl:value-of select="@target"/>
	  </xsl:with-param>
	</xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:when>
<!-- other uses of target means it is external -->
  <xsl:when test="@target">
    <xsl:call-template name="makeExternalLink">
      <xsl:with-param name="ptr" select="$ptr"/>
      <xsl:with-param name="dest">
	<xsl:value-of select="@target"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:when>
  <!-- If there is a url attribute starting with #, it is a local
       reference -->
  <xsl:when test="@url and starts-with(@url,'#')">
    <xsl:call-template name="makeInternalLink">
      <xsl:with-param name="target" select="substring-after(@url,'#')"/>
      <xsl:with-param name="ptr" select="$ptr"/>
      <xsl:with-param name="dest">
	<xsl:call-template name="generateEndLink">
	  <xsl:with-param name="where">
	    <xsl:value-of select="substring-after(@url,'#')"/>
	  </xsl:with-param>
	</xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:when>
  <!-- otherwise it is an external URL -->
  <xsl:when test="@url">
    <xsl:call-template name="makeExternalLink">
      <xsl:with-param name="ptr" select="$ptr"/>
      <xsl:with-param name="dest">
	<xsl:value-of select="@url"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:when>
<!-- A doc attribute means an external reference -->
    <xsl:when test="@doc">
      <xsl:call-template name="makeExternalLink">
	<xsl:with-param name="ptr" select="$ptr"/>
	<xsl:with-param name="dest">
	    <xsl:value-of select="unparsed-entity-uri(@doc)"/>
	</xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
<!--
      <xsl:for-each select="@*">
	[[markup error: <xsl:value-of select="name(.)"/>=<xsl:value-of select="."/>]]
      </xsl:for-each>
-->
      <xsl:apply-templates/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>
</xsl:stylesheet>