from __future__ import annotations

from collections import Counter
from pathlib import Path
from typing import Any
from xml.dom import minidom
import xml.etree.ElementTree as ET

from flask import Flask, Response, render_template, request, send_file

BASE_DIR = Path(__file__).resolve().parent
XML_PATH = BASE_DIR / "transport.xml"
XSL_PATH = BASE_DIR / "trains.xsl"

DAY_LABELS = {
    "mon": "Monday",
    "tue": "Tuesday",
    "wed": "Wednesday",
    "thu": "Thursday",
    "fri": "Friday",
    "sat": "Saturday",
    "sun": "Sunday",
}

app = Flask(__name__)


def parse_days(raw_value: str) -> list[str]:
    return [DAY_LABELS.get(part.strip().lower(), part.strip()) for part in raw_value.split(",") if part.strip()]


def get_element_tree_root() -> ET.Element:
    return ET.parse(XML_PATH).getroot()


def build_station_map(root: ET.Element) -> dict[str, str]:
    stations = root.find("stations")
    if stations is None:
        return {}

    return {
        station.attrib["id"]: station.attrib["name"]
        for station in stations.findall("station")
    }


def get_filters_metadata() -> dict[str, Any]:
    root = get_element_tree_root()
    station_names = [station.attrib["name"] for station in root.findall("./stations/station")]
    train_types: list[str] = []

    for trip in root.findall("./lines/line/trips/trip"):
        trip_type = trip.attrib["type"]
        if trip_type not in train_types:
            train_types.append(trip_type)

    return {
        "stations": station_names,
        "train_types": train_types,
    }


def build_trip_record(line: ET.Element, trip: ET.Element, station_map: dict[str, str]) -> dict[str, Any]:
    schedule = trip.find("schedule")
    days_text = (trip.findtext("days") or "").strip()
    classes = [
        {
            "type": class_node.attrib["type"],
            "price": int(class_node.attrib["price"]),
        }
        for class_node in trip.findall("class")
    ]

    cheapest_class = min(classes, key=lambda item: item["price"])
    priciest_class = max(classes, key=lambda item: item["price"])

    return {
        "line_code": line.attrib["code"],
        "departure_city": station_map.get(line.attrib["departure"], line.attrib["departure"]),
        "arrival_city": station_map.get(line.attrib["arrival"], line.attrib["arrival"]),
        "trip_code": trip.attrib["code"],
        "train_type": trip.attrib["type"],
        "schedule": {
            "departure": schedule.attrib["departure"] if schedule is not None else "",
            "arrival": schedule.attrib["arrival"] if schedule is not None else "",
        },
        "days": parse_days(days_text),
        "classes": classes,
        "cheapest_class": cheapest_class,
        "priciest_class": priciest_class,
    }


def filter_trips(
    departure: str = "",
    arrival: str = "",
    train_type: str = "",
    max_price: int | None = None,
) -> list[dict[str, Any]]:
    root = get_element_tree_root()
    station_map = build_station_map(root)
    results: list[dict[str, Any]] = []

    for line in root.findall("./lines/line"):
        departure_city = station_map.get(line.attrib["departure"], line.attrib["departure"])
        arrival_city = station_map.get(line.attrib["arrival"], line.attrib["arrival"])

        if departure and departure_city.lower() != departure.lower():
            continue
        if arrival and arrival_city.lower() != arrival.lower():
            continue

        for trip in line.findall("./trips/trip"):
            if train_type and trip.attrib["type"].lower() != train_type.lower():
                continue

            record = build_trip_record(line, trip, station_map)
            visible_classes = record["classes"]

            if max_price is not None:
                visible_classes = [item for item in visible_classes if item["price"] <= max_price]
                if not visible_classes:
                    continue

            record["visible_classes"] = visible_classes
            record["visible_min_price"] = min(item["price"] for item in visible_classes)
            record["visible_max_price"] = max(item["price"] for item in visible_classes)
            results.append(record)

    return results


def get_trip_by_code_dom(trip_code: str) -> dict[str, Any] | None:
    normalized_code = trip_code.strip().upper()
    if not normalized_code:
        return None

    document = minidom.parse(str(XML_PATH))
    station_map = {
        node.getAttribute("id"): node.getAttribute("name")
        for node in document.getElementsByTagName("station")
    }

    for line in document.getElementsByTagName("line"):
        for trip in line.getElementsByTagName("trip"):
            if trip.getAttribute("code").upper() != normalized_code:
                continue

            schedule_nodes = trip.getElementsByTagName("schedule")
            schedule = schedule_nodes[0] if schedule_nodes else None
            days_nodes = trip.getElementsByTagName("days")
            raw_days = ""
            if days_nodes and days_nodes[0].firstChild:
                raw_days = days_nodes[0].firstChild.nodeValue.strip()

            classes = []
            for class_node in trip.getElementsByTagName("class"):
                classes.append(
                    {
                        "type": class_node.getAttribute("type"),
                        "price": int(class_node.getAttribute("price")),
                    }
                )

            return {
                "line_code": line.getAttribute("code"),
                "departure_city": station_map.get(line.getAttribute("departure"), line.getAttribute("departure")),
                "arrival_city": station_map.get(line.getAttribute("arrival"), line.getAttribute("arrival")),
                "trip_code": trip.getAttribute("code"),
                "train_type": trip.getAttribute("type"),
                "schedule": {
                    "departure": schedule.getAttribute("departure") if schedule is not None else "",
                    "arrival": schedule.getAttribute("arrival") if schedule is not None else "",
                },
                "days": parse_days(raw_days),
                "classes": classes,
            }

    return None


def compute_statistics() -> dict[str, Any]:
    root = get_element_tree_root()
    station_map = build_station_map(root)
    line_summaries: list[dict[str, Any]] = []
    trip_type_counts: Counter[str] = Counter()

    for line in root.findall("./lines/line"):
        trip_summaries = []

        for trip in line.findall("./trips/trip"):
            record = build_trip_record(line, trip, station_map)
            trip_type_counts[record["train_type"]] += 1
            trip_summaries.append(record)

        if not trip_summaries:
            continue

        cheapest_trip = min(trip_summaries, key=lambda item: item["cheapest_class"]["price"])
        priciest_trip = max(trip_summaries, key=lambda item: item["priciest_class"]["price"])

        line_summaries.append(
            {
                "line_code": line.attrib["code"],
                "departure_city": station_map.get(line.attrib["departure"], line.attrib["departure"]),
                "arrival_city": station_map.get(line.attrib["arrival"], line.attrib["arrival"]),
                "trip_count": len(trip_summaries),
                "cheapest_trip": cheapest_trip,
                "priciest_trip": priciest_trip,
            }
        )

    return {
        "line_summaries": line_summaries,
        "trip_type_counts": dict(sorted(trip_type_counts.items())),
        "max_trip_type_count": max(trip_type_counts.values(), default=1),
    }


@app.route("/")
def index() -> str:
    metadata = get_filters_metadata()
    search_code = request.args.get("search_code", "").strip()
    departure = request.args.get("departure", "").strip()
    arrival = request.args.get("arrival", "").strip()
    train_type = request.args.get("train_type", "").strip()
    max_price_raw = request.args.get("max_price", "").strip()

    max_price: int | None = None
    validation_error = ""
    if max_price_raw:
        try:
            max_price = int(max_price_raw)
        except ValueError:
            validation_error = "Maximum price must be an integer value."

    trip_detail = get_trip_by_code_dom(search_code) if search_code else None
    trips = filter_trips(departure=departure, arrival=arrival, train_type=train_type, max_price=max_price)
    statistics = compute_statistics()

    return render_template(
        "index.html",
        filters=request.args,
        stations=metadata["stations"],
        train_types=metadata["train_types"],
        trip_detail=trip_detail,
        trips=trips,
        statistics=statistics,
        validation_error=validation_error,
        searched_code=search_code,
    )


@app.route("/transport.xml")
def transport_xml() -> Response:
    return send_file(XML_PATH, mimetype="application/xml")


@app.route("/trains.xsl")
def trains_xsl() -> Response:
    return send_file(XSL_PATH, mimetype="text/xsl")


if __name__ == "__main__":
    app.run(debug=True)
