using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class Return : MonoBehaviour
{
    public void ReturnGame()
    {
        SceneManager.LoadScene("SelectScene");
    }
}
