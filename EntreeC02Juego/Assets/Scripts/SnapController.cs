using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class SnapController : MonoBehaviour
{
    public List<Transform> snapPoints; // Variable que se ajusta a los puntos donde deben estar los objetos
    public List<DragDrop> draggableObject; // Varibale lista de objetos arrastrables
    public float snapRange = 0.5f; // Variable que especifica que tan cerca debe estar el objeto


    void Start()
    {
        foreach(DragDrop draggable in draggableObject){
            draggable.dragEndedCallback = OnDragEnd; 
        }
    }

    // Funcion que controla la aproximacion del objeto al destino 
    private void OnDragEnd(DragDrop draggable){
        float closesDistance = -1;
        Transform closesSnapPoint = null;

        foreach(Transform snapPoint in snapPoints){
            float currentDistance = Vector2.Distance(draggable.transform.localPosition, snapPoint.localPosition);
            if (closesSnapPoint == null || currentDistance < closesDistance ){
                closesDistance = currentDistance;
                closesSnapPoint = snapPoint;
            }
        }

        if(closesSnapPoint != null && closesDistance <= snapRange){
            draggable.transform.localPosition = closesSnapPoint.localPosition;
        }


    }
}
