using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class SnapController : MonoBehaviour
{
    public Transform snapPoints; // Variable que se ajusta a los puntos donde deben estar los objetos
    public List<DragDrop> draggableObject; // Varibale lista de objetos arrastrables
    public List<string> correctOr;
    public float snapRange = 0.5f; // Variable que especifica la distancia maxima para que el objeto encaje

    private List<DragDrop> placedObject = new List<DragDrop>();
    private int correctOrder = 0;

    void Start()
    {
        correctOr = new List<string> { "Ingrediente7", "Ingrediente2","Ingrediente8","Ingrediente4","Ingrediente1","Ingrediente3","Ingrediente6","Ingrediente5"};

        foreach(DragDrop draggable in draggableObject)
        {
            draggable.dragEndedCallback = OnDragEnd; 
        }
    }

    // Funcion que controla la aproximacion del objeto al destino 
    private void OnDragEnd(DragDrop draggable)
    {
        float currenDistance = Vector2.Distance(draggable.transform.localPosition, snapPoints.localPosition);
        if(currenDistance <= snapRange)
        {
            if(correctOrder < correctOr.Count && draggable.name == correctOr[correctOrder])
            {
                placedObject.Add(draggable); //Agrega el objeto 
                draggable.transform.localPosition = snapPoints.localPosition; //colocalo en el snap point 
                draggable.transform.SetSiblingIndex(placedObject.Count - 1);
                correctOrder++;
                Debug.Log($"{draggable.name} colocado. Orden actual: {placedObject.Count}");
            }
            else
            {
                draggable.transform.localPosition = draggable.originalPosition;
                Debug.Log($"{draggable.name} regreso a su posicion");
            }
        }
        else
        {
            draggable.transform.localPosition = draggable.originalPosition;
            Debug.Log($"{draggable.name} regreso a su posicion");
        }
    }
        
}
