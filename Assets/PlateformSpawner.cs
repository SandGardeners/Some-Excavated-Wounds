using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlateformSpawner : MonoBehaviour
{
    public GameObject plateformPrefab;

    private void Update() {
        if(Input.GetMouseButtonDown(1))
        {
            Instantiate(plateformPrefab, transform.position+Camera.main.transform.forward * 4.5f, Quaternion.identity);
        }
    }
}
