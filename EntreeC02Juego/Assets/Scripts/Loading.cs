using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class Loading : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        StartCoroutine(LoadScene());
        
    }

    IEnumerator LoadScene()
    {
        yield return new WaitForSeconds(5f);

        SceneManager.LoadScene("EndGame");
    }	
}
