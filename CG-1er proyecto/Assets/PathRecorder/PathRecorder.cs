using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class PathRecorder
{
    private static List<Vector3> points = new List<Vector3>();
    private static Transform trackedTransform;

    public static void RecordPoint(Transform trackedTransform, Vector3 localOffset)
    {
        if (PathRecorder.trackedTransform != trackedTransform)
        {
            points.Clear();
            PathRecorder.trackedTransform = trackedTransform;
        }
        
        points.Add(trackedTransform.TransformPoint(localOffset));
    }

    public static void Clear() => points.Clear();

    public static List<Vector3> Points => points;
}
