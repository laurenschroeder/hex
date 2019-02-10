// Given downward increasing Y, and rightward increasing X:
//   Polygons are clockwise.
//   Angle is the interior angle of three consecutive points on a polygon.

class Mesh {
    // The data members.
    List<Vector> _vertices;
    List<List<Integer>> _faces;
    // 
    List<List<IdPair>> _flip;
    Map<Vector, Integer> _vertexMap;
    Map<IdPair, Integer> _edgeMap;
    
    // Construct an empty mesh.
    Mesh() {
        _vertices = new ArrayList<Vector>();
        _faces = new ArrayList<List<Integer>>(); // list of lists of vertex ids
        _flip  = new ArrayList<List<IdPair>>(); // (faceId,vertexId) pairs per half-edge.

        // Optimizations to support incremental construction.
        _vertexMap = new HashMap<Vector, Integer>();
        _edgeMap   = new HashMap<IdPair, Integer>();
    }

    int numPerimeterVertices() {
        return perimeterHalfEdges().size(); // TODO: optimize
    }

    int numFaces() {
        return _faces.size();
    }

    int numVertices() {
        return _vertices.size();
    }

    int numEdges() {
        return -1; // TODO
    }

    Poly getFace(int faceId) {
        Poly vertices = new Poly();
        for (int vi : _faces.get(faceId)) vertices.add(getVertex(vi));
        return vertices;
    }

    Vector getVertex(int vertexId) {
        return _vertices.get(vertexId);
    }

    List<HalfEdge> perimeterHalfEdges() {
        List<HalfEdge> result = new ArrayList<HalfEdge>();
        // for fi,face in enumerate(faces()) {
        for (int fi = 0; fi < numFaces(); fi++) {
            for (int fvi = 0; fvi < _faces.get(fi).size(); fvi++) {
                if (hasNoFlip(fi, fvi)) {
                    result.add(halfEdge(fi, fvi));
                }
            }
        }
        return result;
    }

    boolean hasNoFlip(int fi, int fvi) {
        return _flip.get(fi).get(fvi) == null;
    }

    List<Poly> faces() {
        List<Poly> result = new ArrayList<Poly>();
        for (int fi = 0; fi < numFaces(); fi++) {
            result.add(getFace(fi));
        }
        return result;
    }

    // Get any half-edge on the border of this face.
    HalfEdge halfEdgeOnFace(int faceId) {
        return halfEdge(faceId, 0);
    }

    HalfEdge halfEdge(int faceId, int faceVertexId) {
        return new HalfEdge(this, faceId, faceVertexId);
    }

    // Add the given polygon (sequence of vertices) to the mesh. De-duplicate any shared vertices.
    void addPolygon(Poly vertices) {
        List<Integer> face = new ArrayList<Integer>();
        
        for (Vector vertex : vertices.points) {
            int vi;
            if (_vertexMap.containsKey(vertex)) {
                // Lookup the vertex.
                vi = _vertexMap.get(vertex);
            } else {
                // If it doesn't exist, create a new entry.
                vi = _vertices.size();
                _vertexMap.put(vertex, vi);
                _vertices.add(vertex);
            }
            // Include the vertex index in this face.
            face.add(vi);
        }
        _faces.add(face);
        _flip.add(emptyFlip(vertices.size()));
        //_updateFaceAdjacency(_faces.size() - 1);
    }

    List<IdPair> emptyFlip(int n) {
        List<IdPair> result = new ArrayList<IdPair>();
        for (int i = 0; i < n; i++) result.add(null);
        return result;
    }

    /** Update adjacencies for the given face id. */
    //void _updateFaceAdjacency(int faceId) {
    //     // This only works for addition,
    //     // removing faces would require full recalc or different implementation.
    //     fi = len(_faces) - 1
    //     face = _faces[fi]

    //     for (int fvi = 0; fvi < faces.size(); fvi++) {
    //         int vi0 = face.get(fvi); int vi1 = face.get((fvi+1)%face.size());
    //         _edgeMap[(vi0,vi1)] = (fi,fvi);
    //     }

    //     for (int fvi = 0; fvi < faces.size(); fvi++) {
    //         int vi0 = face.get(fvi); int vi1 = face.get((fvi+1)%face.size());
    //         if (vi1,vi0) in _edgeMap {
    //             (fiFlip,fviFlip) = _edgeMap[(vi1,vi0)]
    //             _flip[fi][fvi] = (fiFlip,fviFlip)
    //             _flip[fiFlip][fviFlip] = (fi,fvi)
    //             // Could do the other direction here too. If we wanted.
    //         }
    //     }

    // void recalcAdjacency() {
    //     "Recalculate all adjacencies from scratch."
    //     _edgeMap = {}
    //     for fi,face in enumerate(_faces):
    //     for (int fi = 0; fi < _faces.size(); fi++) {
    //         List<Integer> face = _faces.get(fi)
    //         for (int fvi = 0; fvi < faces.size(); fvi++) {
    //             int vi0 = face.get(fvi); int vi1 = face.get((fvi+1)%face.size());
    //             _edgeMap[(vi0,vi1)] = (fi,fvi)
    //     }

    //     for fi,face in enumerate(_faces):
    //     for (int fi = 0; fi < _faces.size(); fi++) {
    //         List<Integer> face = _faces.get(fi)
    //         for (int fvi = 0; fvi < faces.size(); fvi++) {
    //             int vi0 = face.get(fvi); int vi1 = face.get((fvi+1)%face.size());
    //             try:
    //                 (fiFlip,fviFlip) = _edgeMap[(vi1,vi0)]
    //                 _flip[fi][fvi] = (fiFlip,fviFlip)
    //                 // Could do the other direction here too. If we wanted.
    //             except KeyError:
    //                 pass // Perimeter edge.
    //     }
}

class Poly {
    List<Vector> points;
    Poly() {
        points = new ArrayList<Vector>();
    }

    void add(Vector p) {
        points.add(p);
    }

    int size() {
        return points.size();
    }
}

class HalfEdge {
    Mesh mesh;
    int faceId, faceVertexId;

    HalfEdge(Mesh mesh, int faceId, int faceVertexId) {
        this.mesh = mesh;
        this.faceId = faceId;
        this.faceVertexId = faceVertexId;
    }

    IdPair id() {
        return new IdPair(faceId, faceVertexId);
    }

    IdPair vertexIds() {
        return new IdPair(startVertexId(), endVertexId());
    }

    int startVertexId() {
        return mesh._faces.get(faceId).get(faceVertexId);
    }

    int endVertexId() {
        List<Integer> vertexIds = mesh._faces.get(faceId);
        return vertexIds.get( (faceVertexId+1) % vertexIds.size() );
    }

    Vector startVertex() {
        return mesh._vertices.get(startVertexId());
    }

    Vector endVertex() {
        return mesh._vertices.get(endVertexId());
    }
}

class IdPair {
    int faceId, faceVertexId;
    IdPair(int faceId, int faceVertexId) {
        this.faceId = faceId;
        this.faceVertexId = faceVertexId;
    }
}
