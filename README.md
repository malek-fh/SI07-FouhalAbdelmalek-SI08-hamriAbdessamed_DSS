# Railway Trip Management

This project is based on the `transport.xml` file required in the assignment.

It contains two parts:

- `trains.xsl` transforms the XML file into an HTML page.
- `app.py` runs a Flask web application for search, filtering, and statistics.

## Requirements

- Python 3.10 or newer
- Internet is not required after the files are downloaded

## Install

Open PowerShell in the project folder, the one that contains `app.py`:

```powershell
cd path\to\Dss.mini-project
```

Install Flask:

```powershell
python -m pip install -r requirements.txt
```

## Run the web application

Start the Flask server:

```powershell
python app.py
```

When the server starts, open this address in a browser:

- `http://127.0.0.1:5000/`

## Open the XML/XSLT result

The same project also exposes the XML file through Flask:

- `http://127.0.0.1:5000/transport.xml`

If your browser does not apply the XSLT stylesheet automatically, open `transport.xml` in Oxygen XML Editor.

## Files

- `transport.xml`: source data
- `trains.xsl`: XSLT transformation
- `app.py`: Flask application
- `templates/`: HTML templates used by Flask
- `static/css/style.css`: page styling
- `requirements.txt`: Python dependency list

## What the project does

### Part 1: XSLT

The XSLT page shows:

- each railway line
- the trips in each line
- departure and arrival cities
- train type
- classes and prices
- operating days

### Part 2: Python and XML

The Flask application allows:

- search for a trip by code
- filter by departure city
- filter by arrival city
- filter by train type
- filter by maximum price

It also calculates:

- the cheapest and most expensive trip for each line
- the number of trips for each train type

## XML APIs used

- `xml.dom.minidom` is used for the trip search by code
- `xml.etree.ElementTree` is used for filtering and statistics
