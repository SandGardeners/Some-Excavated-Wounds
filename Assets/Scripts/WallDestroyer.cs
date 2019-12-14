using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class WallDestroyer : MonoBehaviour
{
    public PickaxeAnim piocheanim;
    public PickaxeAnim scanneranim;
    public FirstPersonAIO player;
    int _currentWeight;
    AudioSource source;
    public int CurrentWeight
    {
        get
        {
            return _currentWeight;
        }
        set
        {
            _currentWeight = value;
            player.walkSpeed = Mathf.Lerp(startSpeed,slowestSpeed,Mathf.InverseLerp(0,totalWeight,CurrentWeight));
        }
    }
    public int totalWeight;
    public float slowestSpeed;
    public float startSpeed;



    // Start is called before the first frame update
    void Start()
    {
        source = GetComponent<AudioSource>();
        startSpeed = player.walkSpeed;
    }
    bool ready = true;
    bool readyscan = true;
    void FeedbackHit(RaycastHit? hit)
    {
        ready = true;
        if(hit != null)
        {            
            hit.Value.collider.gameObject.GetComponentInParent<Totem>().TakeDamage();
source.PlayOneShot(piochesound);

        }
    }

    public AudioClip piochesound;
    public AudioClip scansound;
    void OkScanned(RaycastHit? hit)
    {
        readyscan = true;
        if( hit!= null)
        {
            WallPiece p = hit.Value.collider.gameObject.GetComponent<WallPiece>(); 
            CurrentWeight += p.weight;
            p.PickUp();
source.PlayOneShot(scansound);
        }
    }
    public GameObject leftInfo;
    public GameObject rightInfo;
    // Update is called once per frame
    void Update()
    {
        if(!player.playerCanMove)
            return;

        bool leftPossible = false;
        bool rightPossible = false;

        Ray r = Camera.main.ViewportPointToRay(new Vector3(0.5F, 0.5F, 0));
        RaycastHit hit; 
        if(Physics.SphereCast(r, 1f, out hit))
        {
            leftPossible = hit.collider.CompareTag("Destroyed");
            rightPossible =hit.collider.CompareTag("Destructible");  
        }

        leftInfo.SetActive(leftPossible);
        rightInfo.SetActive(rightPossible);

        if(readyscan && Input.GetMouseButtonDown(0))
        {
            readyscan = false;
            if(leftPossible)
                scanneranim.LetsGo(()=>OkScanned(hit));
            else
                scanneranim.LetsGo(()=>OkScanned(null));
        }

        if(ready && Input.GetMouseButton(1))
        {
            ready = false;
            if(rightPossible)
                piocheanim.LetsGo(()=>FeedbackHit(hit));
            else
                piocheanim.LetsGo(()=>FeedbackHit(null));
        }

        // if(readyscan && Input.GetMouseButtonDown(0))
        // {
        //     Ray r = Camera.main.ViewportPointToRay(new Vector3(0.5F, 0.5F, 0));
        //     RaycastHit hit; 
        //     readyscan = false;
        //     if(Physics.SphereCast(r, 1f, out hit) && !string.IsNullOrEmpty(hit.collider.tag))
        //     {
        //         if(hit.collider.CompareTag("Destroyed"))
        //         {
        //             scanneranim.LetsGo(()=>OkScanned(hit));
        //         }
        //         else
        //             scanneranim.LetsGo(()=>OkScanned(null));
        //     }
        //     else
        //     {
        //         scanneranim.LetsGo(()=>OkScanned(null));
        //     }
        // }

        // if(ready && Input.GetMouseButtonDown(1))
        // {
        //     Ray r = Camera.main.ViewportPointToRay(new Vector3(0.5F, 0.5F, 0));
        //     RaycastHit hit; 
        //     ready = false;
        //     if(Physics.SphereCast(r, 1f, out hit) && !string.IsNullOrEmpty(hit.collider.tag))
        //     {
        //         if(hit.collider.CompareTag("Destructible"))
        //         {
        //             piocheanim.LetsGo(()=>FeedbackHit(hit));
        //         }
        //         else
        //         {
        //             piocheanim.LetsGo(()=>FeedbackHit(null));
        //         }
        //     }
        //     else
        //     {
        //         piocheanim.LetsGo(()=>FeedbackHit(null));
        //     }
        // }
    }
}
