using System.Collections;
using System.Collections.Generic;
using System.Text;
using UnityEditor;
using UnityEditor.EditorTools;
using UnityEditor.ShortcutManagement;
using UnityEngine;

[EditorTool("Path Recorder")]
public class PathRecorderTool : EditorTool
{
    private Vector3 localOffset = Vector3.zero;
    
    [Shortcut("Activate Path Recorder Tool", typeof(SceneView), KeyCode.R, ShortcutModifiers.Shift)]
    static void PathRecordedToolShortcut()
    {
        ToolManager.SetActiveTool<PathRecorderTool>();
    }

    public override void OnActivated()
    {
        SceneView.lastActiveSceneView.ShowNotification(new GUIContent("Entering Path Recorder Tool"), .1f);
    }
    
    public override void OnWillBeDeactivated()
    {
        SceneView.lastActiveSceneView.ShowNotification(new GUIContent("Exiting Path Recorder Tool"), .1f);
    }

    public override void OnToolGUI(EditorWindow window)
    {
        if (!(window is SceneView sceneView))
            return;
        if (!(Selection.activeObject is GameObject go)) return;
        
        Transform selectedTransform = go.transform;
        
        
        if (PathRecorder.Points.Count > 1)
        {
            for (int i = 1; i < PathRecorder.Points.Count; i++)
            {
                Handles.color = new Color(1f, 0.38f, 0.38f);
                Handles.FreeMoveHandle(PathRecorder.Points[i], HandleUtility.GetHandleSize(PathRecorder.Points[i]) * 0.03f,
                    Vector3.zero, Handles.DotHandleCap);
                Handles.color = Color.grey;
                Handles.DrawLine(PathRecorder.Points[i - 1], PathRecorder.Points[i], 2f);
            }
        }
        
        EditorGUI.BeginChangeCheck();
        Vector3 startLocalOffset = Handles.PositionHandle(selectedTransform.TransformPoint(localOffset), selectedTransform.rotation);
        Handles.Label(selectedTransform.TransformPoint(localOffset), "Offset");
        if (EditorGUI.EndChangeCheck())
        {
            localOffset = selectedTransform.InverseTransformPoint(startLocalOffset);
        }
        
        Handles.BeginGUI();
        GUILayout.Window(2, new Rect(0, Screen.height-160, 180, 100), (id) =>
        {
            if (GUILayout.Button("Record Point"))
            {
                PathRecorder.RecordPoint(selectedTransform, localOffset);
            }

            if (GUILayout.Button("Reset Local Offset"))
            {
                localOffset = Vector3.zero;
            }

            if (GUILayout.Button("Clear Data"))
            {
                PathRecorder.Clear();
            }
            
            if (GUILayout.Button("Save Data"))
            {
                StringBuilder builder = new StringBuilder();
                builder.Append("{\"UNITY\":");
                builder.Append("[");
                int count = 0;
                foreach (Vector3 vector3 in PathRecorder.Points)
                {
                    if (count > 0) builder.Append(",");
                    builder.Append($"{{\"x\":{vector3.x},\"y\":{vector3.y}, \"z\":{vector3.z}}}");
                    count++;
                }

                builder.Append("]");
                builder.Append("}");
                GUIUtility.systemCopyBuffer = builder.ToString();
                SceneView.lastActiveSceneView.ShowNotification(new GUIContent("Path data recorded in clipboard, you can now go to blender"), 2f);
            }
            
        }, "Path Recorder");
        Handles.EndGUI();

        
    }
}
