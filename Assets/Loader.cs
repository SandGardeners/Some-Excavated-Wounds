using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;
using UnityEngine.UI;
public class Loader : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        GetComponent<Image>().DOColor(Color.clear, 5f).onComplete = ()=>{Destroy(gameObject);};

    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
