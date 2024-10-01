using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class Timer : MonoBehaviour
{
    public float timeRemaining = 0;
    public bool timeRunning = true;
    public TMP_Text timeText;

    // Start is called before the first frame update
    void Start()
    {
        timeRunning = true;
    }

    // Update is called once per frame
    void Update()
    {
        if(timeRunning){
            if(timeRemaining >= 0){
                timeRemaining += Time.deltaTime;
                DisplayTime(timeRemaining);
            }
        }
        
    }
    void DisplayTime(float timeToDisplay){
        timeToDisplay +=1;
        float minutes = Mathf.FloorToInt (timeToDisplay / 60);
        float seconds = Mathf.FloorToInt(timeToDisplay % 60);
        timeText.text = string.Format("{0:00} : {1:00}",minutes, seconds);

    }
}
