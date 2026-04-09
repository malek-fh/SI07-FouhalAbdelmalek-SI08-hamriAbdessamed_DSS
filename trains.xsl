<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" indent="yes" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>

    <xsl:key name="station-by-id" match="station" use="@id"/>

    <xsl:template match="/">
        <html lang="en">
            <head>
                <meta charset="UTF-8"/>
                <title>Train Trips Report</title>
                <style>
                    body {
                        margin: 0;
                        font-family: Cambria, Georgia, "Times New Roman", serif;
                        background:
                            linear-gradient(180deg, rgba(255, 255, 255, 0.46), rgba(255, 255, 255, 0) 220px),
                            radial-gradient(circle at top left, rgba(24, 49, 79, 0.05), transparent 28%),
                            radial-gradient(circle at top right, rgba(138, 107, 63, 0.07), transparent 24%),
                            #f3efe8;
                        color: #1f2933;
                    }

                    .page {
                        max-width: 1420px;
                        margin: 0 auto;
                        padding: 28px 24px 42px;
                    }

                    .header-strip {
                        display: table;
                        width: 100%;
                        margin-bottom: 18px;
                        padding: 12px 18px;
                        border: 1px solid rgba(24, 49, 79, 0.12);
                        border-radius: 12px;
                        background: rgba(255, 255, 255, 0.76);
                        color: #5b6877;
                        font-size: 15px;
                    }

                    .report-header,
                    .line-block {
                        position: relative;
                        background: rgba(255, 255, 255, 0.94);
                        border: 1px solid rgba(24, 49, 79, 0.12);
                        border-radius: 18px;
                        box-shadow: 0 18px 38px rgba(24, 49, 79, 0.08);
                    }

                    .report-header:before,
                    .line-block:before {
                        content: "";
                        position: absolute;
                        left: 0;
                        right: 0;
                        top: 0;
                        height: 4px;
                        border-radius: 18px 18px 0 0;
                        background: linear-gradient(90deg, #18314f, #8a6b3f);
                    }

                    .report-header {
                        display: grid;
                        grid-template-columns: minmax(0, 1.55fr) minmax(260px, 0.7fr);
                        gap: 24px;
                        padding: 30px 32px;
                        margin-bottom: 20px;
                    }

                    .report-header p {
                        margin: 0 0 10px;
                        font-size: 12px;
                        text-transform: uppercase;
                        letter-spacing: 0.14em;
                        color: #8a6b3f;
                        font-weight: bold;
                    }

                    .report-header h1 {
                        margin: 0 0 14px;
                        font-size: 38px;
                        color: #18314f;
                    }

                    .report-header .description {
                        margin: 0 0 18px;
                        color: #5b6877;
                        line-height: 1.65;
                    }

                    .team-panel {
                        padding: 16px 18px;
                        border: 1px solid #d6dce5;
                        border-radius: 14px;
                        background: rgba(255, 255, 255, 0.84);
                    }

                    .team-panel .label {
                        margin: 0 0 10px;
                        font-size: 12px;
                        text-transform: uppercase;
                        letter-spacing: 0.14em;
                        color: #8a6b3f;
                        font-weight: bold;
                    }

                    .team-panel ul {
                        list-style: none;
                        margin: 0;
                        padding: 0;
                    }

                    .team-panel li {
                        display: table;
                        width: 100%;
                        padding: 8px 0;
                        border-bottom: 1px solid rgba(24, 49, 79, 0.08);
                    }

                    .team-panel li:last-child {
                        border-bottom: none;
                        padding-bottom: 0;
                    }

                    .team-panel .name {
                        display: table-cell;
                        color: #1f2933;
                    }

                    .team-panel .group {
                        display: table-cell;
                        text-align: right;
                        white-space: nowrap;
                        color: #5b6877;
                        font-size: 13px;
                        font-weight: bold;
                    }

                    .summary {
                        width: 100%;
                        border-collapse: collapse;
                        background: #ffffff;
                    }

                    .summary th,
                    .summary td,
                    .table th,
                    .table td {
                        border: 1px solid #d6dce5;
                        padding: 10px 12px;
                        text-align: left;
                    }

                    .summary th,
                    .table th {
                        background: #18314f;
                        color: #ffffff;
                    }

                    .line-grid {
                        display: grid;
                        grid-template-columns: repeat(2, minmax(0, 1fr));
                        gap: 18px;
                        align-items: start;
                    }

                    .line-block {
                        padding: 24px;
                    }

                    .line-title {
                        margin: 0 0 6px;
                        font-size: 26px;
                        color: #18314f;
                    }

                    .route {
                        margin: 0 0 18px;
                        color: #5b6877;
                    }

                    .trip-block {
                        margin-top: 16px;
                        padding: 16px;
                        border: 1px solid #d6dce5;
                        border-radius: 12px;
                        background: linear-gradient(180deg, #f5f8fc, rgba(255, 255, 255, 0.96));
                    }

                    .trip-block h3 {
                        margin: 0 0 8px;
                        color: #18314f;
                        font-size: 20px;
                    }

                    .trip-meta {
                        margin: 0 0 10px;
                        color: #5b6877;
                    }

                    .table {
                        width: 100%;
                        border-collapse: collapse;
                        background: #ffffff;
                    }

                    .days {
                        margin: 10px 0 0;
                        color: #334e68;
                    }

                    @media (max-width: 980px) {
                        .report-header,
                        .line-grid {
                            grid-template-columns: 1fr;
                        }
                    }
                </style>
            </head>
            <body>
                <div class="page">
                    <div class="header-strip">Submitted Project | Dataset: transport.xml</div>

                    <div class="report-header">
                        <div>
                            <p>Railway Trip Management</p>
                            <h1>Train Trips Report</h1>
                            <p class="description">HTML report generated from the XML file with XSLT. It shows lines, trips, schedules, classes, prices, and operating days.</p>

                            <table class="summary">
                                <thead>
                                    <tr>
                                        <th>Lines</th>
                                        <th>Trips</th>
                                        <th>Stations</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td><xsl:value-of select="count(transport/lines/line)"/></td>
                                        <td><xsl:value-of select="count(transport/lines/line/trips/trip)"/></td>
                                        <td><xsl:value-of select="count(transport/stations/station)"/></td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>

                        <div class="team-panel">
                            <p class="label">Project Team</p>
                            <ul>
                                <li>
                                    <span class="name">Fouhal Abdelmalek</span>
                                    <span class="group">Gr7</span>
                                </li>
                                <li>
                                    <span class="name">Hamri Abdessamad</span>
                                    <span class="group">Gr8</span>
                                </li>
                                <li>
                                    <span class="name">Boudiar Mohammed El Amine</span>
                                    <span class="group">Gr10</span>
                                </li>
                            </ul>
                        </div>
                    </div>

                    <div class="line-grid">
                        <xsl:for-each select="transport/lines/line">
                            <xsl:sort select="@code"/>
                            <div class="line-block">
                                <xsl:variable name="departureId" select="@departure"/>
                                <xsl:variable name="arrivalId" select="@arrival"/>

                                <h2 class="line-title">Line <xsl:value-of select="@code"/></h2>
                                <p class="route">
                                    Route:
                                    <xsl:value-of select="key('station-by-id', $departureId)/@name"/>
                                    <xsl:text> - </xsl:text>
                                    <xsl:value-of select="key('station-by-id', $arrivalId)/@name"/>
                                </p>

                                <xsl:for-each select="trips/trip">
                                    <xsl:sort select="@code"/>
                                    <div class="trip-block">
                                        <h3>Trip <xsl:value-of select="@code"/></h3>
                                        <p class="trip-meta">
                                            Train type:
                                            <xsl:value-of select="@type"/>
                                            <xsl:text> | Departure: </xsl:text>
                                            <xsl:value-of select="schedule/@departure"/>
                                            <xsl:text> | Arrival: </xsl:text>
                                            <xsl:value-of select="schedule/@arrival"/>
                                        </p>

                                        <table class="table">
                                            <thead>
                                                <tr>
                                                    <th>Schedule</th>
                                                    <th>Train Type</th>
                                                    <th>Class</th>
                                                    <th>Price (DA)</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <xsl:for-each select="class">
                                                    <tr>
                                                        <td>
                                                            <xsl:value-of select="../schedule/@departure"/>
                                                            <xsl:text> - </xsl:text>
                                                            <xsl:value-of select="../schedule/@arrival"/>
                                                        </td>
                                                        <td><xsl:value-of select="../@type"/></td>
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
                </div>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
