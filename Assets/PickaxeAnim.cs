using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PickaxeAnim : MonoBehaviour
{

    Action callback;
    internal void LetsGo(Action feedback)
    {
        GetComponent<Animator>().SetTrigger("oui");
        callback = feedback;
    }

    public void TriggerCallback()
    {
        if(callback != null)
        {
            callback.Invoke();
        }
        
    }
}
