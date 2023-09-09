import 'package:vector_math/vector_math_64.dart';

List<TriPlane> listOfPlanes = [];

setCorrectNormal(List<Vector3> possibleInternalPoints, TriPlane plane) {
  for (Vector3 point in possibleInternalPoints) {
    double dist = dot3(plane.normal, point - plane.pointA);
    if (dist != 0 && dist > 0.000000001) {
      plane.normal *= -1;
      return;
    }
  }
}

bool checkerPlane(TriPlane a, TriPlane b) {
  if (a.pointA == b.pointA) {
    if (a.pointB == b.pointB && a.pointC == b.pointC) {
      return true;
    } else if (a.pointB == b.pointC && a.pointC == b.pointB) {
      return true;
    }
  }
  if (a.pointA == b.pointB) {
    if (a.pointB == b.pointA && a.pointC == b.pointC) {
      return true;
    } else if (a.pointB == b.pointC && a.pointC == b.pointA) {
      return true;
    }
  }
  if (a.pointA == b.pointC) {
    if (a.pointB == b.pointA && a.pointC == b.pointB) {
      return true;
    } else if (a.pointB == b.pointC && a.pointC == b.pointB) {
      return true;
    }
  }
  return false;
}

checkEdges(Edge a, Edge b) =>
    (((a.pointA == b.pointA) && (a.pointB == b.pointB)) || ((a.pointB == b.pointA) && (a.pointA == b.pointB)));

class Edge {
  Vector3 pointA, pointB;
  Edge(this.pointA, this.pointB);

  @override
  bool operator ==(Object other) => (other is Edge) && checkEdges(this, other);
}

class TriPlane {
  Vector3 pointA, pointB, pointC;
  late Vector3 normal;
  late double distance;
  Set<Vector3> toDo = {};
  late Edge edge1 = Edge(pointA, pointB), edge2 = Edge(pointB, pointC), edge3 = Edge(pointC, pointA);

  TriPlane(this.pointA, this.pointB, this.pointC) {
    calcNorm();
  }

  calcNorm() {
    Vector3 point1 = pointA - pointB;
    Vector3 point2 = pointB - pointC;
    normal = point1.cross(point2).normalized();
    distance = normal.dot(pointA);
  }

  double dist(pointX) => normal.dot(pointX - pointA);
  List<Edge> getEdges() => [edge1, edge2, edge3];

  calculateToDo(List<Vector3> points) {
    for (Vector3 p in points) {
      if (dist(p) > 0.000000000001) toDo.add(p);
    }
  }

  @override
  bool operator ==(Object other) => (other is TriPlane) && checkerPlane(this, other);

  @override
  String toString() => [pointA, pointB, pointC].toString();
}

int calcHorizon(List<TriPlane> visitedPlanes, TriPlane plane, Vector3 eyePoint, Set<Edge> edgeList) {
  if (plane.dist(eyePoint) > 0.0000000001) {
    visitedPlanes.add(plane);
    for (Edge edge in plane.getEdges()) {
      TriPlane? neighbor = adjacentPlane(plane, edge);
      if (neighbor != null && !visitedPlanes.contains(neighbor)) {
        if (calcHorizon(visitedPlanes, neighbor, eyePoint, edgeList) == 0) {
          edgeList.add(edge);
        }
      }
    }
    return 1;
  } else {
    return 0;
  }
}

TriPlane? adjacentPlane(TriPlane mainPlane, Edge edge) {
  for (TriPlane plane in listOfPlanes) {
    if ((plane != mainPlane) && plane.getEdges().contains(edge)) {
      return plane;
    }
  }
  return null;
}

double? distLine(Vector3 pointA, Vector3 pointB, Vector3 pointX) {
  Vector3 vec3 = pointB - pointA;
  if (vec3.length == 0) return null;
  return (pointX - pointA).cross(pointX - pointB).length / vec3.length;
}

Vector3 maxDistLinePoint(pointA, pointB, List<Vector3> points) {
  double maxDist = 0;
  Vector3 maxDistPoint = Vector3.zero();
  for (Vector3 point in points) {
    if (pointA != point && pointB != point) {
      double? dist = distLine(pointA, pointB, point);
      if (dist != null) {
        dist = dist.abs();
        if (dist > maxDist) {
          maxDistPoint = point;
          maxDist = dist;
        }
      }
    }
  }
  return maxDistPoint;
}

Vector3 maxDistPlanePoint(TriPlane plane, List<Vector3> points) {
  double maxDist = 0;
  Vector3 maxDistPoint = Vector3.zero();
  for (Vector3 point in points) {
    double dist = plane.dist(point).abs();
    if (dist > maxDist) {
      maxDistPoint = point;
      maxDist = dist;
    }
  }
  return maxDistPoint;
}

Vector3 findEyePoint(TriPlane plane, Set<Vector3> toDoList) {
  double maxDist = 0;
  Vector3 maxDistPoint = Vector3.zero();
  for (Vector3 point in toDoList) {
    double dist = plane.dist(point);
    if (dist > maxDist) {
      maxDist = dist;
      maxDistPoint = point;
    }
  }
  return maxDistPoint;
}

List<Vector3> initialMax(List<Vector3> now) {
  int maxi = -1;
  List<Vector3> found = [];
  for (int i = 0; i < 6; i++) {
    for (int j = i + 1; j < 6; j++) {
      double dist = now[i].distanceTo(now[j]);
      if (dist > maxi) {
        found = [now[i], now[j]];
      }
    }
  }
  return found;
}

List<Vector3> initial(List<Vector3> points) {
  double xMinTemp = double.infinity, xMaxTemp = double.negativeInfinity;
  double yMinTemp = double.infinity, yMaxTemp = double.negativeInfinity;
  double zMinTemp = double.infinity, zMaxTemp = double.negativeInfinity;
  late Vector3 xMax, yMax, zMax, xMin, yMin, zMin;
  for (Vector3 p in points) {
    if (p.x > xMaxTemp) {
      xMaxTemp = p.x;
      xMax = p;
    }
    if (p.x < xMinTemp) {
      xMinTemp = p.x;
      xMin = p;
    }
    if (p.y > yMaxTemp) {
      yMaxTemp = p.y;
      yMax = p;
    }
    if (p.y < yMinTemp) {
      yMinTemp = p.y;
      yMin = p;
    }
    if (p.z > zMaxTemp) {
      zMaxTemp = p.z;
      zMax = p;
    }
    if (p.z < zMinTemp) {
      zMinTemp = p.z;
      zMin = p;
    }
  }

  return [xMax, xMin, yMax, yMin, zMax, zMin];
}

mainHull(List<Vector3> points) {
  List<Vector3> initialLine = initialMax(initial(points));
  Vector3 thirdPoint = maxDistLinePoint(initialLine[0], initialLine[1], points);
  TriPlane firstPlane = TriPlane(initialLine[0], initialLine[1], thirdPoint);
  Vector3 fourthPoint = maxDistPlanePoint(firstPlane, points);

  List<Vector3> possibleInternalPoints = [initialLine[0], initialLine[1], thirdPoint, fourthPoint];
  TriPlane secondPlane = TriPlane(initialLine[0], initialLine[1], fourthPoint);
  TriPlane thirdPlane = TriPlane(initialLine[0], fourthPoint, thirdPoint);
  TriPlane fourthPlane = TriPlane(initialLine[1], thirdPoint, fourthPoint);

  listOfPlanes = [firstPlane, secondPlane, thirdPlane, fourthPlane];

  for (TriPlane p in listOfPlanes) {
    setCorrectNormal(possibleInternalPoints, p);
    p.calculateToDo(points);
  }

  bool anyPlanesLeft = true;
  while (anyPlanesLeft) {
    anyPlanesLeft = false;
    for (TriPlane workingPlane in listOfPlanes.sublist(0)) {
      if (workingPlane.toDo.isNotEmpty) {
        anyPlanesLeft = true;
        Vector3 eyePoint = findEyePoint(workingPlane, workingPlane.toDo);
        Set<Edge> edgeList = {};
        List<TriPlane> visitedPlanes = [];
        calcHorizon(visitedPlanes, workingPlane, eyePoint, edgeList);
        for (TriPlane internalPlane in visitedPlanes) {
          listOfPlanes.remove(internalPlane);
        }
        for (Edge edge in edgeList) {
          TriPlane newPlane = TriPlane(edge.pointA, edge.pointB, eyePoint);
          setCorrectNormal(possibleInternalPoints, newPlane);
          Set<Vector3> tempToDo = {};
          for (TriPlane internalPlane in visitedPlanes) {
            tempToDo = tempToDo.union(internalPlane.toDo);
          }
          newPlane.calculateToDo(tempToDo.toList());
          listOfPlanes.add(newPlane);
        }
      }
    }
  }

  List<TriPlane> finalPlanes = [];
  for (TriPlane p in listOfPlanes) {
    if (!finalPlanes.contains(p)) {
      finalPlanes.add(p);
    }
  }
  Set<Vector3> finalVertices = {};
  List<int> finalIndices = [];
  for (TriPlane plane in finalPlanes) {
    for (Vector3 point in [plane.pointA, plane.pointB, plane.pointC]) {
      finalVertices.add(point);
    }
    finalIndices.addAll([
      for (Vector3 point in [plane.pointA, plane.pointB, plane.pointC]) finalVertices.toList().indexOf(point)
    ]);
  }
  return [finalVertices, finalIndices];
}
