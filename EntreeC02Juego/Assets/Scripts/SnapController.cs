using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class SnapController : MonoBehaviour
{
    public Transform snapPoints; // Variable que se ajusta a los puntos donde deben estar los objetos
    public List<DragDrop> draggableObject; // Varibale lista de objetos arrastrables
    public float snapRange = 0.5f; // Variable que especifica la distancia maxima para que el objeto encaje

    private List<DragDrop> placedObject = new List<DragDrop>();

    void Start()
    {
        
        foreach(DragDrop draggable in draggableObject){
            draggable.dragEndedCallback = OnDragEnd; 
        }
    }

    // Funcion que controla la aproximacion del objeto al destino 
    private void OnDragEnd(DragDrop draggable)
    {
        float currenDistance = Vector2.Distance(draggable.transform.localPosition, snapPoints.localPosition);
        if(currenDistance <= snapRange)
        {
            if(!placedObject.Contains(draggable))
            {
                placedObject.Add(draggable); //Agrega el objeto 
                draggable.transform.localPosition = snapPoints.localPosition; //colocalo en el snap point 
                draggable.transform.SetSiblingIndex(placedObject.Count - 1);
                Debug.Log($"{draggable.name} colocado. Orden actual: {placedObject.Count}");
            }

        }
    }
        
}
