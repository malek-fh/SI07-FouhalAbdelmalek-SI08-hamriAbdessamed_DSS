<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" indent="yes" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>

    <xsl:key name="station-by-id" match="station" use="@id"/>

    <xsl:template match="/">
        <html lang="en">
            <head>
                <meta charset="UTF-8"/>
                <title>Trips from transport.xml</title>
                <style>
                    body {
                        margin: 0;
                        font-family: Cambria, Georgia, "Times New Roman", serif;
                        background: #f4f1ea;
                        color: #1f2933;
                    }

                    .page {
                        width: 1100px;
                        max-width: calc(100% - 40px);
                        margin: 0 auto;
                        padding: 24px 0 36px;
                    }

                    .header,
                    .team-box,
                    .line-box,
                    .trip-box {
                        background: #ffffff;
                        border: 1px solid #d8dee8;
                        border-radius: 12px;
                    }

                    .header {
                        display: table;
                        width: 100%;
                        margin-bottom: 18px;
                        padding: 24px;
                    }

                    .header-left,
                    .header-right {
                        display: table-cell;
                        vertical-align: top;
                    }

                    .header-right {
                        width: 280px;
                        padding-left: 18px;
                    }

                    .header p {
                        margin: 0 0 8px;
                        color: #8a6b3f;
                        font-size: 12px;
                        font-weight: bold;
                        text-transform: uppercase;
                        letter-spacing: 0.12em;
                    }

                    .header h1 {
                        margin: 0 0 10px;
                        color: #18314f;
                        font-size: 34px;
                    }

                    .header .description {
                        margin: 0;
                        color: #5b6877;
                        line-height: 1.6;
                    }

                    .team-box {
                        padding: 14px 16px;
                    }

                    .team-box h2 {
                        margin: 0 0 10px;
                        color: #18314f;
                        font-size: 18px;
                    }

                    .team-box ul {
                        margin: 0;
                        padding: 0;
                        list-style: none;
                    }

                    .team-box li {
                        display: table;
                        width: 100%;
                        padding: 8px 0;
                        border-bottom: 1px solid #edf1f5;
                    }

                    .team-box li:last-child {
                        border-bottom: none;
                    }

                    .name,
                    .group {
                        display: table-cell;
                    }

                    .group {
                        text-align: right;
                        color: #5b6877;
                        font-weight: bold;
                        white-space: nowrap;
                    }

                    .line-box {
                        margin-bottom: 18px;
                        padding: 20px;
                    }

                    .line-box h2 {
                        margin: 0 0 6px;
                        color: #18314f;
                        font-size: 24px;
                    }

                    .route {
                        margin: 0 0 16px;
                        color: #5b6877;
                    }

                    .trip-box {
                        margin-top: 14px;
                        padding: 14px;
                    }

                    .trip-box h3 {
                        margin: 0 0 6px;
                        color: #18314f;
                        font-size: 18px;
                    }

                    .trip-meta {
                        margin: 0 0 10px;
                        color: #5b6877;
                    }

                    table {
                        width: 100%;
                        border-collapse: collapse;
                    }

                    th,
                    td {
                        padding: 10px 12px;
                        border: 1px solid #d8dee8;
                        text-align: left;
                    }

                    th {
                        background: #18314f;
                        color: #ffffff;
                    }

                    .days {
                        margin: 10px 0 0;
                        color: #334e68;
                    }
                </style>
            </head>
            <body>
                <div class="page">
                    <div class="header">
                        <div class="header-left">
                            <p>XSLT Output</p>
                            <h1>Trips by Line</h1>
                            <p class="description">Structured view of the trips stored in transport.xml.</p>
                        </div>

                        <div class="header-right">
                            <div class="team-box">
                                <h2>Project Team</h2>
                                <ul>
                                    <li>
                                        <span class="name">Fouhal Abdelmalek</span>
                                        <span class="group">Gr7</span>
                                    </li>
                                    <li>
                                        <span class="name">Hamri Abdessamad</span>
                                        <span class="group">Gr8</span>
                                    </li>
                                </ul>
                            </div>
                        </div>
                    </div>

                    <xsl:for-each select="transport/lines/line">
                        <xsl:sort select="@code"/>
                        <div class="line-box">
                            <xsl:variable name="departureId" select="@departure"/>
                            <xsl:variable name="arrivalId" select="@arrival"/>

                            <h2>Line <xsl:value-of select="@code"/></h2>
                            <p class="route">
                                <xsl:value-of select="key('station-by-id', $departureId)/@name"/>
                                <xsl:text> - </xsl:text>
                                <xsl:value-of select="key('station-by-id', $arrivalId)/@name"/>
                            </p>

                            <xsl:for-each select="trips/trip">
                                <xsl:sort select="@code"/>
                                <div class="trip-box">
                                    <h3>Trip <xsl:value-of select="@code"/></h3>
                                    <p class="trip-meta">
                                        Type:
                                        <xsl:value-of select="@type"/>
                                        <xsl:text> | Schedule: </xsl:text>
                                        <xsl:value-of select="schedule/@departure"/>
                                        <xsl:text> - </xsl:text>
                                        <xsl:value-of select="schedule/@arrival"/>
                                    </p>

                                    <table>
                                        <thead>
                                            <tr>
                                                <th>Class</th>
                                                <th>Price (DA)</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <xsl:for-each select="class">
                                                <tr>
                                                    <td><xsl:value-of select="@type"/></td>
                                                    <td><xsl:value-of select="@price"/></td>
                                                </tr>
                                            </xsl:for-each>
                                        </tbody>
                                    </table>

                                    <p class="days">
                                        Operating days:
                                        <xsl:value-of select="days"/>
                                    </p>
                                </div>
                            </xsl:for-each>
                        </div>
                    </xsl:for-each>
                </div>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
