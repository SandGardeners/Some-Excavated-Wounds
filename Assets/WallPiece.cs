using System;
using System.Collections;
using System.Collections.Generic;
using DG.Tweening;
using UnityEngine;

public class WallPiece : MonoBehaviour
{
    new Rigidbody rigidbody;
    public new Renderer renderer;

    public int weight;
    
    // Start is called before the first frame update
    void Start()
    {
        // weight = UnityEngine.Random.Range(20,200);
        renderer = GetComponent<Renderer>();
        rigidbody = GetComponent<Rigidbody>();
    }

    // Update is called once per frame
    void Update()
    {
        
    }
    int life = 0;

    public void TakeDamage()
    {
        rigidbody.isKinematic = false;
        rigidbody.velocity = (transform.position-Camera.main.transform.position).normalized*15f;
        ItemsTracker.tracker.AddRenderer(this);
        this.tag = "Destroyed";
    }

    public void PickUp()
    {
        ItemsTracker.tracker.RemoveRenderer(this);
        Destroy(gameObject);
    }
}
