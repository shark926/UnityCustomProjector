using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class MyProjector : MonoBehaviour
{
    [SerializeField]
    private float size = 10;

    [SerializeField]
    private float nearClip = 0.1f;

    [SerializeField]
    private float farClip = 10f;

    [SerializeField]
    private Material decalMat;

    [SerializeField]
    private List<MeshFilter> meshFilters;

    private void Update()
    {
        float half = size / 2f;
        var orthoProjector = Matrix4x4.Ortho(-half, half, -half, half, nearClip, farClip);
        var projectionMatrix = GL.GetGPUProjectionMatrix(orthoProjector, false);
        var vpMatrix = projectionMatrix * this.transform.worldToLocalMatrix;
        decalMat.SetMatrix("_DecalVPMatrix", vpMatrix);
        decalMat.SetVector("_DecalProjectorDir", this.transform.forward * -1f);

        for (int i = 0; i < meshFilters.Count; ++i)
        {
            var go = meshFilters[i];
            var mesh = go.sharedMesh;
            Graphics.DrawMesh(mesh, go.transform.localToWorldMatrix, decalMat, 6);
        }
    }

    private void OnDrawGizmosSelected()
    {
        Vector3 s = new Vector3(size, size, farClip - nearClip);
        var origin = Gizmos.matrix;
        Gizmos.matrix = transform.localToWorldMatrix;
        Gizmos.DrawWireCube(new Vector3(0f, 0f, -(farClip+nearClip)/2), s);
        Gizmos.matrix = origin;
    }
}
