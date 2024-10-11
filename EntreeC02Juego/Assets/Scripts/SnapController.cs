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
        // Variable que contiene la lista correcta en que deben ir los ingredientes 
        correctOr = new List<string> { "Ingrediente7", "Ingrediente2","Ingrediente8","Ingrediente4","Ingrediente1","Ingrediente3","Ingrediente6","Ingrediente5"};

        foreach(DragDrop draggable in draggableObject)
        {
            draggable.dragEndedCallback = OnDragEnd; 
        }
    }

    // Funcion que controla la aproximacion del objeto al destino 
    private void OnDragEnd(DragDrop draggable)
    {
        float currenDistance = Vector2.Distance(draggable.transform.position, snapPoints.position);
        if(currenDistance <= snapRange)
        {
            // Verifica si el objeto es el correcto para colocar
            if(correctOrder < correctOr.Count && draggable.name == correctOr[correctOrder])
            {
                // El ingrediente es colocado en el snap point
                placedObject.Add(draggable); //Agrega el objeto 
                draggable.transform.position = snapPoints.position; //colocalo en el snap point 
                draggable.transform.SetSiblingIndex(placedObject.Count - 1);
                correctOrder++;
                Debug.Log($"{draggable.name} colocado. Orden actual: {placedObject.Count}");
            }
            else
            {
                // Si no es el ingrediente correcto, regresa a su posicion
                draggable.transform.position = draggable.originalPosition;
                Debug.Log($"{draggable.name} regreso a su posicion");
            }
        }
        else
        {
            // Si el ingrediente no es puesto cerca del rango, se devuelve su posicion
            draggable.transform.position = draggable.originalPosition;
            Debug.Log($"{draggable.name} regreso a su posicion");
        }
    }
        
}
