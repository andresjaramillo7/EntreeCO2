using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DragDrop : MonoBehaviour
{
    public delegate void DragEndedDelegate(DragDrop draggableObject); //Variable que almacena la referencia a un metodo, en este caso la aproximacion
    public DragEndedDelegate dragEndedCallback;

    private bool isDragged = false;
    private Vector3 mouseDragStart;
    private Vector3 spriteDragStart;

    private void OnMouseDown() {
        isDragged = true;
        mouseDragStart = Camera.main.ScreenToWorldPoint(Input.mousePosition);
        spriteDragStart = transform.localPosition;
        
    }

    private void OnMouseDrag() {
        if(isDragged == true){
            transform.localPosition = spriteDragStart + (Camera.main.ScreenToWorldPoint(Input.mousePosition) - mouseDragStart);

        }
    }
    private void OnMouseUp() {
        isDragged = false;
        dragEndedCallback(this);
    }

    
}
