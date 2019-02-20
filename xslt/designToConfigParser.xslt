<?xml version="1.0" encoding="UTF-8"?>
<!-- author pnikiel -->
<xsl:transform version="2.0" xmlns:xml="http://www.w3.org/XML/1998/namespace" 
xmlns:xs="http://www.w3.org/2001/XMLSchema" 
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:d="http://cern.ch/quasar/Design"
xmlns:fnc="http://cern.ch/quasar/MyFunctions"
xsi:schemaLocation="http://www.w3.org/1999/XSL/Transform ../../Design/schema-for-xslt20.xsd ">
	<xsl:include href="../../Design/CommonFunctions.xslt" />
	<xsl:output method="text"></xsl:output>
    <xsl:param name="typePrefix"/>
    <xsl:param name="serverName"/>
    <xsl:param name="driverNumber"/>
    <xsl:param name="subscriptionName"/>
	

    <xsl:function name="fnc:cacheVariableToMode">
    <xsl:param name="addressSpaceWrite"/>
    <xsl:choose>
    <xsl:when test="$addressSpaceWrite='forbidden'">DPATTR_ADDR_MODE_INPUT_SPONT</xsl:when>
    <xsl:otherwise>DPATTR_ADDR_MODE_IO_SPONT</xsl:otherwise>
    </xsl:choose>
    </xsl:function>
   
	<xsl:template match="/">	
    // generated using Cacophony, an optional module of quasar
    // generated at: TODO
    
    
    
    <xsl:for-each select="/d:design/d:class">
    void configure<xsl:value-of select="@name"/> (int docNum, int childNode, string prefix)
    {
        DebugTN("Configure.<xsl:value-of select="@name"/> called");
        string name;
        xmlGetElementAttribute(docNum, childNode, "name", name);
        string fullName = prefix+name;
        string dpt = "MyQuasarServer"+"<xsl:value-of select="@name"/>";
        DebugTN("Will create DP "+fullName);
        int result = dpCreate(fullName, dpt);
        
        string dpe, address;
        dyn_string dsExceptionInfo;
        <xsl:for-each select="d:cachevariable">
        dpe = fullName+".<xsl:value-of select='@name'/>";
        address = dpe; // address can be generated from dpe after some mods ...
        strreplace(address, "/", ".");
        fwPeriphAddress_setOPCUA (
            dpe /*dpe*/,
            "<xsl:value-of select='$serverName'/>" /* server name*/,
            <xsl:value-of select="$driverNumber"/>,
            "ns=2;s="+address,
            "<xsl:value-of select='$subscriptionName'/>" /* subscription*/,
            1 /* kind */,
            1 /* variant */,
            750 /* datatype */,
            <xsl:value-of select="fnc:cacheVariableToMode(@addressSpaceWrite)"/> /* mode */,
            "" /*poll group */,
            dsExceptionInfo
            );
        </xsl:for-each>
        
        dyn_int children;
        <xsl:for-each select="d:hasobjects[@instantiateUsing='configuration']">
        children = getChildNodesWithName(docNum, childNode, "<xsl:value-of select='@class'/>");
        for (int i=1; i&lt;=dynlen(children); i++)
        configure<xsl:value-of select="@class"/> (docNum, children[i], fullName+"/");
        </xsl:for-each>
        
    }
    <!-- 
        <xsl:call-template name="hasObjects">
        <xsl:with-param name="parentClass">Root</xsl:with-param>
        </xsl:call-template>  -->
    </xsl:for-each>
    
    dyn_int getChildNodesWithName (int docNum, int parentNode, string name)
    {
        dyn_int result;
        int node = xmlFirstChild(docNum, parentNode);
        while (node >= 0)
        {
            if (xmlNodeName(docNum, node)==name)
                dynAppend(result, node);
            node = xmlNextSibling (docNum, node);
        }
        return result;
    }
    
    int main (string configFileName)
    /* Create instances */
    {
        string errMsg;
        int errLine;
        int errColumn;
        int docNum = xmlDocumentFromFile(configFileName, errMsg, errLine, errColumn);
        if (docNum &lt; 0)
        {
            DebugN("Didn't open the file: at Line="+errLine+" Column="+errColumn+" Message=" + errMsg);
            return -1;
        }
               
        int firstNode = xmlFirstChild(docNum);
        if (firstNode &lt; 0)
        {
            DebugN("Cant get the first child of the config file.");
            return -1;
        }
        while (xmlNodeName(docNum, firstNode) != "configuration")
        {
            firstNode = xmlNextSibling(docNum, firstNode);
            if (firstNode &lt; 0)
            {
                DebugTN("configuration node not found, sorry.");
                return -1;
            }
        }
        // now firstNode holds configuration node   
        dyn_int children;
        <xsl:for-each select="/d:design/d:root/d:hasobjects[@instantiateUsing='configuration']">
       
        dyn_int children = getChildNodesWithName(docNum, firstNode, "<xsl:value-of select='@class'/>");
        for (int i = 1; i&lt;=dynlen(children); i++)
        {
            configure<xsl:value-of select="@class"/> (docNum, children[i], "");
        }
       
        </xsl:for-each>
        
        return 0;
    }
    
    </xsl:template>



</xsl:transform>
