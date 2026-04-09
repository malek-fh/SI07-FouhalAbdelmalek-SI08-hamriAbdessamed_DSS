# Railway Trip Management

This project uses the `transport.xml` file from the assignment.

It contains:

- `trains.xsl` for the XML to HTML transformation
- a Flask application for search, filtering, and statistics

## Files

- `transport.xml`: source XML file
- `trains.xsl`: XSLT file
- `app.py`: Flask application
- `templates/`: HTML templates
- `static/css/style.css`: interface styling

## Required functions

### Part 1

The XSLT report shows:

- railway lines
- trips for each line
- departure and arrival cities
- train type
- classes and prices
- operating days

### Part 2

The Flask application allows:

- search by trip code
- filter by departure city
- filter by arrival city
- filter by train type
- filter by maximum price

It also displays:

- trip details using `xml.dom.minidom`
- the cheapest and most expensive trip for each line using `xml.etree.ElementTree`
- the number of trips for each train type

## Run

From PowerShell:

```powershell
python app.py
```

Then open:

- `http://127.0.0.1:5000/`
- `http://127.0.0.1:5000/transport.xml`
